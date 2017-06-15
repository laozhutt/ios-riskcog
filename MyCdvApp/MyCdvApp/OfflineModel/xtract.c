#include <string.h>
#include <stdlib.h>

#include  "get_func.h"

void pt(int  ind , float x){
    printf("%d : %.2f\n" , ind, x);
}
void print_XYZ(float (*func)(float v[], int size), float X[], float Y[],
		float Z[], int size, int *cnt, float res[]) {
	//	printf("%.2lf ", func(X, size));
	//	printf("%.2lf ", func(Y, size));
	//	printf("%.2lf ", func(Z, size));
    
	res[*cnt] = func(X, size);
	*cnt = *cnt + 1;
	res[*cnt] = func(Y, size);
	*cnt = *cnt + 1;
	res[*cnt] = func(Z, size);
	*cnt = *cnt + 1;
}

void output(int size, float *X, float *Y, float *Z, float *wX, float *wY,
		float *wZ, float *gX, float *gY, float *gZ, float res[]) {
	int cnt = 0;
    print_XYZ(get_mean, X, Y, Z, size, &cnt, res);
    print_XYZ(get_variance, X, Y, Z, size, &cnt, res);
    print_XYZ(get_standard_deviation, X, Y, Z, size, &cnt, res);
    print_XYZ(get_average_deviation, X, Y, Z, size, &cnt, res);
    print_XYZ(get_skewness, X, Y, Z, size, &cnt, res);
    print_XYZ(get_kurtosis, X, Y, Z, size, &cnt, res);
    print_XYZ(get_zcr, X, Y, Z, size, &cnt, res);
    print_XYZ(get_rms_amplitude, X, Y, Z, size, &cnt, res);
    print_XYZ(get_lowest_value, X, Y, Z, size, &cnt, res);
    print_XYZ(get_highest_value, X, Y, Z, size, &cnt, res);
    
    //printf("%.2f ", get_result(X, Y, Z, size));
    res[cnt] = get_result(X, Y, Z, size);
    cnt++;
    
    print_XYZ(get_mean, wX, wY, wZ, size, &cnt, res);
    print_XYZ(get_variance, wX, wY, wZ, size, &cnt, res);
    print_XYZ(get_standard_deviation, wX, wY, wZ, size, &cnt, res);
    print_XYZ(get_average_deviation, wX, wY, wZ, size, &cnt, res);
    print_XYZ(get_skewness, wX, wY, wZ, size, &cnt, res);
    print_XYZ(get_kurtosis, wX, wY, wZ, size, &cnt, res);
    print_XYZ(get_zcr, wX, wY, wZ, size, &cnt, res);
    print_XYZ(get_rms_amplitude, wX, wY, wZ, size, &cnt, res);
    print_XYZ(get_lowest_value, wX, wY, wZ, size, &cnt, res);
    print_XYZ(get_highest_value, wX, wY, wZ, size, &cnt, res);
    
    //printf("%.2lf ", get_result(wX, wY, wZ, size));
    res[cnt] = get_result(wX, wY, wZ, size);


}
