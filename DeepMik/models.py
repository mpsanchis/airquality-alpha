import torch
import torch.nn as nn
import torch.nn.functional as F
from torch.autograd import *


station_id = {'ES0691A':1, 'ES1396A':2, 'ES1438A':3, 'ES1480A':4, 'ES1679A':5, 'ES1856A':6, 'ES1992A':7}

class SimpleModel1(nn.Module):
    def __init__(self, hidden_size, batch_size):
        super(SimpleModel1, self).__init__()

        self.hidden_size = hidden_size
        self.batch_size = batch_size

        self.station_embedding = nn.Linear(7,1)
        self.lstm = nn.LSTMCell(3, hidden_size)
        self.fc_output = nn.Linear(self.hidden_size, 1)

        self.h_x, self.c_x = self.init_state()

    def init_state(self):
        h_0 = torch.zeros(self.batch_size, self.hidden_size)
        c_0 = torch.zeros(self.batch_size, self.hidden_size)

        return (Variable(h_0), Variable(c_0))

    def forward(self, id_station_one_hot, c_mod_prev, c_mod_same):
        id_station_embedded = self.station_embedding(id_station_one_hot)
        x_ = torch.Tensor(c_mod_prev, c_mod_same)
        x = torch.cat(id_station_embedded, x_)
        self.h_x, self.c_x = self.lstm(x, (self.h_x, self.c_x))

        out = self.fc_output(F.sigmoid(self.h_x))
        return out


class SimpleModel2(nn.Module):
    def __init__(self, hidden_size):
        super(SimpleModel1, self).__init__()

        self.hidden_size = hidden_size

        self.fc_input = nn.Linear(2,1)
        self.lstm = nn.LSTMCell(7, hidden_size)
        self.fc_output = nn.Linear(self.hidden_size, 7)

        self.h_x, self.c_x = self.init_state()

    def init_state(self):
        h_0 = torch.zeros(self.hidden_size)
        c_0 = torch.zeros(self.hidden_size)

        return (Variable(h_0), Variable(c_0))

    def forward(self, x):
        x = F.tanh(self.fc_input(x))
        self.h_x, self.c_x = self.lstm(x, (self.h_x, self.c_x))
        out = self.fc_output(F.tanh(self.h_x))
        return out



