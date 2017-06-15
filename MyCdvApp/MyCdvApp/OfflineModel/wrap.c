//
//  CFile.c
//  testCallCpp
//
//  Created by list on 2017/1/1.
//  Copyright © 2017年 list. All rights reserved.
//

#include "wrap.h"
#include <unistd.h>   
#include "predict.h"
#include "svm.h"

void doClassification(float* valuesArr,
                            int * indicesArr, int isProb, char * modelFile,
                            int * labelsArr, double* probsArr, int colNum) {
    
    int *labels = labelsArr;
    double *probs = probsArr;
    
    //here should be fix?
    
    float *values = valuesArr;
    int *indices = indicesArr;
    
    
     predict(values, indices,colNum, isProb, modelFile, labels,
                    probs);
    
    
}
