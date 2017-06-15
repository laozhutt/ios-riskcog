
#include <string.h>
#include <stdio.h>
#include <math.h>
#include "predict.h"
#include "svm-predict.h"

#define LOG_TAG "PREDICT"


struct svm_model* modelt = NULL;

int predict(float *values, int *indices,  int colNum, int isProb,
        const char *modelFile, int *labels, double* prob_estimates) {
    //printf("Coming into classification\n");

    return svmpredict(values, indices,  colNum, isProb, modelFile, labels, prob_estimates, modelt);
}
