#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <math.h>
#include "svm.h"
#include "svm-predict.h"
#define LOG_TAG "PREDICT"

struct svm_node *x;
int max_nr_attr = 64;


//int enable_predict_probability=0;

static char *line = NULL;
static int max_line_len;

static char* readline(FILE *input)
{
	int len;
	
	if(fgets(line,max_line_len,input) == NULL)
		return NULL;

	while(strrchr(line,'\n') == NULL)
	{
		max_line_len *= 2;
		line = (char *) realloc(line,max_line_len);
		len = (int) strlen(line);
		if(fgets(line+len,max_line_len-len,input) == NULL)
			break;
	}
	return line;
}

void exit_input_error_predict(int line_num)
{
	printf("Wrong input format at line %d\n", line_num);
	exit(1);
}

int predict(float *value, int *index,  int colNum, int *labels, double *prob_estimates, int isProb, svm_model *model)
{
	int svm_type=svm_get_svm_type(model);
	int nr_class=svm_get_nr_class(model);
	int j;
	
	if(isProb)
	{
		if (svm_type==NU_SVR || svm_type==EPSILON_SVR)
			printf("Prob. model for test data: target value = predicted value + z,\nz: Laplace distribution e^(-|z|/sigma)/(2sigma),sigma=%g\n",svm_get_svr_probability(model));
		else
		{
			int *labels=(int *) malloc(nr_class*sizeof(int));
			svm_get_labels(model,labels);
		//	fprintf(output,"labels");		
		//	for(j=0;j<nr_class;j++)
		//		fprintf(output," %d",labels[j]);
		//	fprintf(output,"\n");
		//	free(labels);
		}
	}

            double target_label, predict_label=0;
            x = (struct svm_node *) realloc(x,(colNum+1)*sizeof(struct svm_node));

            for (int j = 0; j < colNum; j++)
            {
                x[j].index = index[j];
                x[j].value = value[j];
            }
            x[colNum].index = -1;

            // Probability prediction 
            if (isProb && (svm_type==C_SVC || svm_type==NU_SVC))
            {
                    predict_label = svm_predict_probability(model,x,prob_estimates);
                //printf("test : %lf\n",predict_label);
					*labels=trunc(predict_label + 0.5);
 
            }
            else { *labels = trunc(svm_predict(model,x) + 0.5); }

        return 0;
}

void exit_with_help_for_predict()
{
	printf(
	"Usage: svm-predict [options] test_file model_file output_file\n"
	"options:\n"
	"-b probability_estimates: whether to predict probability estimates, 0 or 1 (default 0); for one-class SVM only 0 is supported\n"
	);
	exit(1);
}

int svmpredict(float *values, int *indices, int colNum,
        int isProb, const char *modelFile, int *labels, double * prob_estimates, svm_model *model)
{
	if(model==NULL && (model=svm_load_model(modelFile))==0)
	{
		printf("can't open model file %s\n",modelFile);
		exit(1);
	}

	x = (struct svm_node *) malloc(max_nr_attr*sizeof(struct svm_node));
	if(isProb)
	{
		if(svm_check_probability_model(model)==0)
		{
			printf("Model does not support probabiliy estimates\n");
			exit(1);
		}
	}
	else
	{
		if(svm_check_probability_model(model)!=0)
			printf("Model supports probability estimates, but disabled in prediction.\n");
	}

	int r = predict(values, indices, colNum, labels, prob_estimates, isProb, model);
	//LOGD("in svmpredict %.2f", prob_estimates[0]);
	//svm_free_and_destroy_model(&model);
	free(x);
	free(line);
	return r;
}
