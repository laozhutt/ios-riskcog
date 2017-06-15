/*
 * Copyright (C) 2011 http://www.csie.ntu.edu.tw/~cjlin/libsvm/
 * Ported by likunarmstrong@gmail.com
 */

#ifndef SVM_PREDICT_H
#define SVM_PREDICT_H
#include "svm.h"

__BEGIN_DECLS
int svmpredict(float *values, int *indices,  int colNum,
        int isProb, const char *modelFile, int *labels, double* prob_estimates, svm_model *model);
__END_DECLS
#endif
