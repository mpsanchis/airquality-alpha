import torch
import torch.nn as nn
import torch.nn.functional as F
from torch.autograd import Variable

import argparse
import numpy as np
import random
import math
import time
from nltk import tokenize
import pandas as pd
import os

import models as models


station_id = {'ES0691A':1, 'ES1396A':2, 'ES1438A':3, 'ES1480A':4, 'ES1679A':5, 'ES1856A':6, 'ES1992A':7}


def main(args):
    # Create the model directory if it does not exist
    if not os.path.exists(args.model_path):
        os.makedirs(args.model_path)

    # Load the dataset:
    df = pd.read_csv(args.dataset_name)

    #TODO: Change the model
    # Create the model:
    model = models.SimpleModel2(args.hidden_size)

    # Set CRITERION and OPTIMIZER:
    criterion = nn.CrossEntropyLoss()
    optimizer = torch.optim.Adam(model.parameters(), lr=args.learning_rate)

    # Start the TRAINING PROCESS:
    losses = []
    start = time.time()

    for epoch in range(args.num_epochs):

        running_loss = 0.0

        for i_batch in range(num_batches):

            # Create the batch
            the_batch = create_input_tensor(df, )
            labels = create_target_tensor(df, )

            # Turn tensors into Variable
            the_batch = to_var(the_batch)
            labels = to_var(labels)

            # Zero the gradients
            optimizer.zero_grad()

            # Forward + Backward + Optimize
            outputs = model(the_batch)

            loss = criterion(outputs, labels)
            loss.backward()
            optimizer.step()
            losses.append(loss.data[0])
            running_loss += loss.data[0]

            if i_batch % args.log_step == 0:
                print('(%s) [%d, %5d] loss: %.4f' %
                      (timeSince(start, ((epoch) * num_batches + i_batch + 1.0) / (args.num_epochs * num_batches)),
                       epoch + 1, (i_batch + 1) * args.batch_size, running_loss / args.log_step))
                running_loss = 0.0

    # SAVE MODELS:
    torch.save(model.state_dict(), args.model_path + args.model_name + '.pkl')
    print('::---TRAINING DONE---::')


# FUNCTIONS USED IN THE TRAINING PROCESS:

def create_input_tensor(dataframe):

    dataframe.sort_values(by=['DatetimeBegin'])
    c_mod_prev = dataframe['ConcentrationModPrev'][sample_indx]
    c_mod_same = dataframe['ConcentrationModSame'][sample_indx]

    return

def create_target_tensor(dataframe):


    return labels


# ==============================================
# - CUSTOM FUNCTIONS
# ==============================================

def to_var(x, volatile=False):
    if torch.cuda.is_available():
        x = x.cuda()
    return Variable(x, volatile=volatile)

def asMinutes(s):
    m = math.floor(s / 60)
    s -= m * 60
    return '%dm %ds' % (m, s)

def timeSince(since, percent):
    now = time.time()
    s = now - since
    es = s / percent
    rs = es - s
    return '%s (- %s)' % (asMinutes(s), asMinutes(rs))


# =============================================================================
# - PARAMETERS
# =============================================================================

if __name__ == '__main__':
    parser = argparse.ArgumentParser()

    # ==================================================================================================================
    # MODEL PARAMETERS
    # ------------------------------------------------------------------------------------------------------------------
    parser.add_argument('--model', type=str, default='conv',
                        help='name of the model to be trained; { conv | lstm }')
    parser.add_argument('--batch_size', type=int, default=1,
                        help='mini-batch size')
    parser.add_argument('--hidden_size', type=int, default=1,
                        help='size of the output of the lstm')

    # ==================================================================================================================
    # OPTIMIZATION
    # ------------------------------------------------------------------------------------------------------------------
    parser.add_argument('--num_epochs', type=int, default=3,
                        help='number of iterations where the system sees all the data')
    parser.add_argument('--learning_rate', type=float, default=0.001)
    parser.add_argument('--weight_decay', type=float, default=0)
    parser.add_argument('--momentum', type=float, default=0.9)

    # ==================================================================================================================
    # SAVING & PRINTING
    # ------------------------------------------------------------------------------------------------------------------
    parser.add_argument('--model_path', type=str, default='./saved_models/',
                        help='path were the models should be saved')
    parser.add_argument('--log_step', type=int, default=10,
                        help='step size for printing the log info')
    parser.add_argument('--save_step', type=int, default=5000,
                        help='step size for saving the trained models')

    # ==================================================================================================================
    # RESOURCES
    # ------------------------------------------------------------------------------------------------------------------

    parser.add_argument('--dataset_name', type=str, default='clean_data.csv',
                        help='Name of the file containing the dataset')
    parser.add_argument('--model_name', type=str, default='model',
                        help='Name of the model to be stored as .pkl | No .pkl needed')

    # __________________________________________________________________________________________________________________
    args = parser.parse_args()
    print(args)
    main(args)


