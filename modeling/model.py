# FINAL SUBMISSION SCRIPT

FEAT = ['Station','weekday','hour','day','year','month',
        'ConcentrationModPrev','ConcentrationModSame','lat','lon','height',
        'd_sea','d_monjuic','d_tibidabo','d_diagonal','d_plcat','d_campnou',
        'd_rondaD','d_rondaB','d_airport','is_weekend','is_holiday',
        'daily_low_pred','yearly_low_pred','ConcentrationObsPrevDay',
        'ConcentrationObsPrevWeek','DayGradient','WeekGradient']
CATS = [0,1]

LR_R, NT_R = 0.01, 1000
LR_C, NT_C = 0.005, 1500

# IMPORTS ######################################################################

import numpy as np
import pandas as pd

from catboost import CatBoostClassifier
from catboost import CatBoostRegressor
from catboost import Pool
from sklearn.metrics import log_loss

# PREPROCESSING ################################################################

# READ DATA

D = pd.read_csv('../data/enriched_data.csv')

# CREATE DATETIME

D['DateTime'] = pd.to_datetime(D['DateBegin']+' '+D['TimeBegin'])

# CREATE TARGET

D['HourTarget'] = D['ConcentrationObs'] > 100
D['HourTarget'] = np.array(D['HourTarget'].fillna(False))
D['DayTarget'] = np.array(D.groupby(['DateBegin','Station'])['HourTarget'].transform('max'),dtype='bool')

# DIVIDE TRAINDATA AND PREDDATA

DX = D[D['DateTime'] < pd.to_datetime('2015')].copy()
DY = D[D['DateTime'] >= pd.to_datetime('2015')].copy()
DY = DY[DY['DateTime'] < pd.to_datetime('2016')].copy()

# HOURLY CONCENTRATION ESTIMATION ##############################################

RDX = DX[DX['ConcentrationObs'].notnull()].copy()

m = CatBoostRegressor(learning_rate=LR_R,iterations=NT_R,logging_level='Silent')
m.fit(RDX[FEAT],y=RDX['ConcentrationObs'],cat_features=CATS)

DX['ConcentrationPred'] = m.predict(Pool(DX[FEAT],cat_features=CATS))
DY['ConcentrationPred'] = m.predict(Pool(DY[FEAT],cat_features=CATS))

FEAT += ['ConcentrationPred']

# HOURLY HIGH-CONCENTRATION PROBABILITY ESTIMATION #############################

m = CatBoostClassifier(learning_rate=LR_C,iterations=NT_C,logging_level='Silent')
m.fit(DX[FEAT],y=DX['HourTarget'],cat_features=CATS)

# DAILY HIGH-CONCENTRATION PROBABILITY ESTIMATION ##############################

fday = lambda x: 1-np.prod(1-x.nlargest(5))

DX['HourPred'] = m.predict_proba(DX[FEAT])[:,1]
DX['DayPred'] = DX.groupby(['DateBegin','Station'])['HourPred'].transform(fday)

DY['HourPred'] = m.predict_proba(DY[FEAT])[:,1]
DY['DayPred'] = DY.groupby(['DateBegin','Station'])['HourPred'].transform(fday)

# TRAINING / TEST LOSS COMPUTATION #############################################

lltr = log_loss(DX['DayTarget'],DX['DayPred'])

MDY = DY[DY.ConcentrationObs.notnull()]
llte = log_loss(MDY['DayTarget'],MDY['DayPred'])

# SUBMISSION CREATION ##########################################################

S = pd.read_csv('../data/target_order.csv')

DY = DY[['DateBegin','Station','DayPred']]
K = pd.merge(S,DY,left_on=['date','station'],right_on=['DateBegin','Station'])
K = K.drop_duplicates()

K['DayPred'].to_csv('../subs/submission.csv',index=False,header=['target'])
