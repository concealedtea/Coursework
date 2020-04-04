# -*- coding:utf-8 -*-
import ConfigParser
import os
from copy import deepcopy
import random
import time

from numpy import *
from sklearn.metrics import roc_auc_score


class LogisticRegression:
    def __init__(self, fi_config):
        self.fi_config = fi_config
        cf = ConfigParser.ConfigParser()
        cf.read(fi_config)
        self.fi_features_schema = cf.get("path", "fi_features_schema")
        self.folder_fw_ref = cf.get("path", "folder_fw_ref")
        self.name_fw_ref = cf.get("name", "name_fw_ref")
        self.folder_train = cf.get("path", "folder_train")
        self.name_fi_train = cf.get("name", "name_fi_train")
        self.folder_test = cf.get("path", "folder_test")
        self.name_fi_test = cf.get("name", "name_fi_test")
        self.eta = cf.getfloat("lr", "eta")
        self.lamb = cf.getfloat("lr", "lamb")
        self.initWeight = cf.getfloat("lr", "initWeight")
        print "LogisticRegression V1"
        print "     fi_features_schema:", self.fi_features_schema
        print "     data_fw_ref:", self.folder_fw_ref, "/", self.name_fw_ref
        print "     data_train:", self.folder_train, "/", self.name_fi_train
        print "     data_test:", self.folder_test, "/", self.name_fi_test
        print "     eta:", self.eta
        print "     lamb", self.lamb
        print "     initWeight", self.initWeight
        print " "

        if not os.path.exists(self.folder_fw_ref):
            os.makedirs(self.folder_fw_ref)
        if not os.path.exists(self.fi_features_schema):
            print " Can not find file:", self.fi_features_schema

        self.fi_fw_ref = self.folder_fw_ref + "/" + self.name_fw_ref
        self.fi_train = self.folder_train + "/" + self.name_fi_train
        self.fi_test = self.folder_test + "/" + self.name_fi_test
    @staticmethod
    def __load_schema(fi_features_schema):
        try:
            ls_features_schema = []
            with open(fi_features_schema, "r") as fi:
                for line in fi:
                    if line.strip() and not line.startswith("#"):
                        ls = line.strip().split("|")
                        position = int(ls[0])
                        feature = ls[1]
                        if not feature.startswith("#"):
                            ls_features_schema.append((position, feature))

            # print "     Method load_schema: result length and pos[0]", len(ls_features_schema), ls_features_schema[0]
            return ls_features_schema
        except Exception, e:
            print Exception, "load_schema:", e
            return []

    @staticmethod
    def __load_kv(path_fi_fw):
        try:
            dict_fw = {}
            if os.path.exists(path_fi_fw):
                with open(path_fi_fw, "r") as fi:
                    for line in fi:
                        if line.strip():
                            ls = line.strip().split("|")
                            if len(ls) == 4:
                                position = int(ls[0])
                                feature = ls[1]
                                feature_value = ls[2]
                                weight = float(ls[3])
                                if (position, feature) in dict_fw:
                                    dict_fw[(position, feature)][feature_value] = weight
                                else:
                                    dict_fw[(position, feature)] = {feature_value: weight}
            return dict_fw
        except Exception, e:
            print Exception, "load_kv:", e
            return {}

    @staticmethod
    def __sigmoid(p):
        return 1.0 / (1 + exp(-p))

    def __nextInitWeight(self, if_zero):
        if if_zero:
            return 0
        else:
            random.seed(10)
            return (random.random() - 0.5) * self.initWeight

    def run_lr(self):
        try:
            ls_features_schema = self.__load_schema(self.fi_features_schema)
            dict_fw = self.__load_kv(self.fi_fw_ref)
            dict_fw_buffer = deepcopy(dict_fw)
            with open(self.fi_train, "r") as fi:
                for line in fi:
                    if line.strip():
                        lss = line.strip().split("$$$")
                        ls_bsf = lss[1].split("|")
                        clk = int(ls_bsf[2])
                        ls = lss[0].split("|")
                        pred = 0.0
                        for (p, feature) in ls_features_schema:
                            feat = ls[p]
                            if feat != "":
                                if (p, feature) not in dict_fw:
                                    dict_fw[(p, feature)] = {feat: self.__nextInitWeight(False)}
                                else:
                                    if feat not in dict_fw[(p, feature)]:
                                        dict_fw[(p, feature)][feat] = self.__nextInitWeight(False)
                                pred += dict_fw[(p, feature)][feat]
                        pred = self.__sigmoid(pred)
                        for (p, feature) in ls_features_schema:
                            feat = ls[p]
                            if feat != "":
                                dict_fw[(p, feature)][feat] = dict_fw[(p, feature)][feat] * (1 - self.lamb) + self.eta * (clk - pred)

            y = []
            yp = []
            yp_buffer = []
            with open(self.fi_test, "r") as fi:
                for line in fi:
                    if line.strip():
                        lss = line.strip().split("$$$")
                        ls_bsf = lss[1].split("|")
                        clk = int(ls_bsf[2])
                        ls = lss[0].split("|")
                        pred = 0.0
                        pred_buffer = 0.0
                        for (p, feature) in ls_features_schema:
                            if (p, feature) in dict_fw:
                                feat = ls[p]
                                if feat in dict_fw[(p, feature)]:
                                    if (p, feature) in dict_fw:
                                        pred += dict_fw[(p, feature)][feat]
                            if (p, feature) in dict_fw_buffer:
                                feat = ls[p]
                                if feat in dict_fw_buffer[(p, feature)]:
                                    if (p, feature) in dict_fw_buffer:
                                        pred_buffer += dict_fw_buffer[(p, feature)][feat]

                        sig_pred = self.__sigmoid(pred)
                        sig_pred_buffer = self.__sigmoid(pred_buffer)
                        y.append(clk)
                        yp.append(sig_pred)
                        yp_buffer.append(sig_pred_buffer)
            auc1 = roc_auc_score(y, yp)
            auc2 = roc_auc_score(y, yp_buffer)
            del y, yp, yp_buffer
            print auc1, auc2, auc1 - auc2
            if auc1 >= auc2:
                del dict_fw_buffer
                return dict_fw
            else:
                del dict_fw
                return dict_fw_buffer

        except Exception, e:
            print Exception, "run_lr:", e
            return {}


if __name__ == "__main__":
    '''
        Functional test
    '''
    start = time.time()
    fi_config = "/home/thatq/PycharmProjects/ctr/MainMethods/Version1/Config/ctrV1.conf"
    lr = LogisticRegression(fi_config)
    dict_fw = lr.run_lr()
    cf = ConfigParser.ConfigParser()
    cf.read(fi_config)
    folder_fw_ref = cf.get("path", "folder_fw_ref")
    name_fw_ref = cf.get("name", "name_fw_ref")
    fi_fw_ref = folder_fw_ref + "/" + name_fw_ref
    fo = open(fi_fw_ref, "w")
    for (p, feature) in dict_fw:
        for feat in dict_fw[(p, feature)]:
            fo.write(str(p) + "|" + str(feature) + "|" + str(feat) + "|" + str(dict_fw[(p, feature)][feat]) + "\r\n")
    fo.close()
    del dict_fw
    # gc.collect()
    end = time.time()
    print "OK", end - start
