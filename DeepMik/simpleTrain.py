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

import simpleModels as models


station_id = {'ES0691A':1, 'ES1396A':2, 'ES1438A':3, 'ES1480A':4, 'ES1679A':5, 'ES1856A':6, 'ES1992A':7}


def main(args):
    # Create the model directory if it does not exist
    if not os.path.exists(args.model_path):
        os.makedirs(args.model_path)

    # Load the dataset:
    df = pd.read_csv(args.dataset_name)
    df_size = df.size
    df_sorted = df.sort_values(['DateBegin', 'month', 'weekday', 'hour', 'Station'])

    #TODO: Change the model
    # Create the model:
    model = models.SimpleModelMadafaka(args.hidden_size, batch_size=args.batch_size)

    # Set CRITERION and OPTIMIZER:
    criterion = nn.MSELoss()
    optimizer = torch.optim.Adam(model.parameters(), lr=args.learning_rate)

    # Start the TRAINING PROCESS:
    losses = []
    start = time.time()

    num_samples = df_size // 7
    num_batches_train = int(num_samples*0.7 // args.batch_size)
    num_batches_test = int(num_samples * 0.2 // args.batch_size)
    print num_batches_train+num_batches_test

    for epoch in range(args.num_epochs):

        running_loss = 0.0


        # Sample the inputs in a random order
        sample_list = random.sample(range((num_batches_test+num_batches_train)*args.batch_size), (num_batches_test+num_batches_train)*args.batch_size)  # List with the input order
        sample_list_iterator = iter(sample_list)

        for i_batch in range(num_batches_train):
            print i_batch
            # Create the batch
            hour_tensor, weekday_tensor, month_tensor, mod_tensor, target_tensor = create_tensors(df_sorted, sample_list_iterator, args.batch_size)

            # Turn tensors into Variable
            hour_v = to_var(hour_tensor)
            weekday_v = to_var(weekday_tensor)
            month_v = to_var(month_tensor)
            mod_v = to_var(mod_tensor)

            labels = to_var(target_tensor)

            # Zero the gradients
            optimizer.zero_grad()

            # Forward + Backward + Optimize
            outputs = model(hour_v, weekday_v, month_v, mod_v)

            loss = criterion(outputs, labels)
            loss.backward()
            optimizer.step()
            losses.append(loss.data[0])
            running_loss += loss.data[0]

            if i_batch % args.log_step == 0:
                print('(%s) [%d, %5d] loss: %.4f' %
                      (timeSince(start, ((epoch) * num_batches_train + i_batch + 1.0) / (args.num_epochs * num_batches_train)),
                       epoch + 1, (i_batch + 1) * args.batch_size, running_loss / args.log_step))
                running_loss = 0.0

        # EVALUATION:
        def test():
            print 'Evaluation___'
            model.eval()
            test_loss = 0
            for i in range(num_batches_test):
                d, target = create_tensors(df_sorted, sample_list_iterator, args.batch_size)
                output = model(d)
                test_loss += criterion(output, target).data[0]

            test_loss /= num_batches_test
            print('----- TEST LOSS %d: %.3f' % (epoch, test_loss))

        test()

    # SAVE MODELS:
    torch.save(model.state_dict(), args.model_path + args.model_name + '.pkl')
    print('::---TRAINING DONE---::')








# FUNCTIONS USED IN THE TRAINING PROCESS:

def create_tensors(df_sorted, sample_list_iterator ,batch_size):

    mod_tensor = torch.zeros(batch_size, 7, 2)
    hour_tensor = torch.zeros(batch_size,24)
    weekday_tensor = torch.zeros(batch_size,7)
    month_tensor = torch.zeros(batch_size, 12)
    target_tensor = torch.zeros(batch_size, 7)



    for e in range(batch_size):
        i = next(sample_list_iterator)
        mod_tensor[e,:,:] = torch.from_numpy(df_sorted[['ConcentrationModPrev', 'ConcentrationModSame']][i*7+1:i*7+8].values)
        target_tensor[e,:] =torch.from_numpy(df_sorted[['ConcentrationObs']][i*7+1:i*7+8].values)

        #One hots:
        hour_tensor[e,df_sorted['hour'][i*7+1]-1]=1
        weekday_tensor[e,df_sorted['weekday'][i*7+1]-1]=1
        month_tensor[e,df_sorted['month'][i*7+1]-1]=1


    #input_tensor = torch.from_numpy(input_matrix)
    #target_tensor = torch.from_numpy(target_matrix)

    return hour_tensor,weekday_tensor,month_tensor, mod_tensor, target_tensor




# ==============================================
# - CUSTOM FUNCTIONS
# ==============================================

def to_var(x, volatile=False):
    #if torch.cuda.is_available():
    #    x = x.cuda()
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
    parser.add_argument('--batch_size', type=int, default=50,
                        help='mini-batch size')
    parser.add_argument('--hidden_size', type=int, default=14,
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

    parser.add_argument('--dataset_name', type=str, default='mikmik.csv',
                        help='Name of the file containing the dataset')
    parser.add_argument('--model_name', type=str, default='model',
                        help='Name of the model to be stored as .pkl | No .pkl needed')

    # __________________________________________________________________________________________________________________
    args = parser.parse_args()
    print(args)
    main(args)