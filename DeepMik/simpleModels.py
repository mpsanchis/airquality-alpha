import torch
import torch.nn as nn
import torch.nn.functional as F
from torch.autograd import *


station_id = {'ES0691A':1, 'ES1396A':2, 'ES1438A':3, 'ES1480A':4, 'ES1679A':5, 'ES1856A':6, 'ES1992A':7}

class SimpleModelMadafaka(nn.Module):
    def __init__(self, hidden_size, embed_size=2, batch_size=1):
        super(SimpleModelMadafaka, self).__init__()

        self.hidden_size = hidden_size
        self.embed_size = embed_size
        self.batch_size = batch_size

        self.hour_embedding = nn.Linear(24, embed_size)
        self.weekday_embedding = nn.Linear(7, embed_size)
        self.month_embedding = nn.Linear(12, embed_size)

        self.fc_1 = nn.Linear(7 *2 +self.embed_size * 3, hidden_size)
        self.fc_2 = nn.Linear(hidden_size, 7)


    def forward(self, hour_t, weekday_t, month_t, mod_t):
        """

        :param hour_t: Tensor [7x24]
        :param weekday_t: Tensor [7x7]
        :param month_t: Tensor [7x12]
        :param mod_t: Tensor [7x2]
        :return: Tensor [7x1]
        """

        hour_emb = self.hour_embedding(hour_t).unsqueeze(1)
        weekday_emb = self.weekday_embedding(weekday_t).unsqueeze(1)
        month_emb = self.month_embedding(month_t).unsqueeze(1)

        x = torch.cat((mod_t, hour_emb, weekday_emb, month_emb), 1)

        x = x.view(-1, 7 *2 +self.embed_size * 3 )

        x = F.tanh(self.fc_1(x))
        x = self.fc_2(x)

        return x


class HourLSTM(nn.Module):
    def __init__(self, hidden_size):
        super(HourLSTM, self).__init__()

        self.hidden_size = hidden_size

        self.lstm = nn.LSTMCell(7, hidden_size)
        self.fc_output = nn.Linear(self.hidden_size, 7)

    def init_state(self):
        h_0 = torch.zeros(self.hidden_size)
        c_0 = torch.zeros(self.hidden_size)

        return (Variable(h_0), Variable(c_0))

    def forward(self, x):
        h_x, c_x = self.init_state()
        self.h_x, self.c_x = self.lstm(x, (self.h_x, self.c_x))
        out = self.fc_output(F.tanh(self.h_x))
        return out


class WeekDayLSTM(nn.Module):
    def __init__(self, hidden_size):
        super(WeekDayLSTM, self).__init__()
        self.hidden_size = hidden_size

        self.lstm = nn.LSTMCell(7, hidden_size)
        self.fc_output = nn.Linear(self.hidden_size, 7)

    def init_state(self):
        h_0 = torch.zeros(self.hidden_size)
        c_0 = torch.zeros(self.hidden_size)

        return (Variable(h_0), Variable(c_0))

    def forward(self, x):
        h_x, c_x = self.init_state()
        self.h_x, self.c_x = self.lstm(x, (self.h_x, self.c_x))
        out = self.fc_output(F.tanh(self.h_x))
        return out




class GlobalScheme(nn.Module):

    def __init__(self, hourlstm_hs, wdlstm_hs):
        super(GlobalScheme, self).__init__()

        self.hour_lstm = HourLSTM(hourlstm_hs)
        self.weekday_lstm = WeekDayLSTM(wdlstm_hs)

