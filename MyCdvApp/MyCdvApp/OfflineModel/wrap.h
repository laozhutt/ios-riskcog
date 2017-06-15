//
//  CFile.h
//  testCallCpp
//
//  Created by list on 2017/1/1.
//  Copyright © 2017年 list. All rights reserved.
//

#ifndef CFile_h
#define CFile_h

#include <stdio.h>

__BEGIN_DECLS
void doClassification(float* valuesArr,
                            int * indicesArr, int isProb, char * modelFiles,
                            int * labelsArr, double* probsArr,  int colNum);

__END_DECLS
#endif /* CFile_h */
