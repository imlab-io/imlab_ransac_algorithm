#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <math.h>
#include "core.h"
#include "prcore.h"

struct linear_fit_data
{
    float m;
    float b;
};

// fit model to given sample data and update the model
void fit(matrix_t *sdata, void *model)
{
    struct linear_fit_data *learnmodel = model;

    // create temp variables
    uint32_t samplesize = rows(sdata);
    float xsum = 0;
    float ysum = 0;
    float xxsum = 0;
    float xysum = 0;

    uint32_t s = 0;
    for(s = 0; s < samplesize; s++)
    {
        float x = atf(sdata, s, 0);
        float y = atf(sdata, s, 1);

        // compute the necessary variables for fitting
        xsum += x;
        ysum += y;
        xysum += x*y;
        xxsum += x*x;
    }

    // use the line fit formulation and compute the line parameters
    learnmodel->m = (samplesize * xysum - xsum * ysum) / (samplesize * xxsum - xsum * xsum);
    learnmodel->b = (ysum - learnmodel->m * xsum) / samplesize;
}

// evaluate all the samples with the learned model and fill the distances array
void distance(matrix_t *data, void *model, float *distances)
{
    struct linear_fit_data *fitmodel = model;

    // create temp variables
    float d = sqrtf(1 + fitmodel->m * fitmodel->m);

    uint32_t s = 0;
    for (s = 0; s < rows(data); s++)
    {
        float x = atf(data, s, 0);
        float y = atf(data, s, 1);

        // compute the distance between a point and the line
        distances[s] = fabs(y - fitmodel->m * x - fitmodel->b) / d;
    }
}

// ransac
struct ransac_t
{
    uint32_t samplesize;
    float maxdistance;
    size_t modelsize;

    // user specified functions
    void (*fitfun)(matrix_t *, void *);
    void (*distfun)(matrix_t *, void *, float *distances);

    // private variables
    void *auxdata;
    void *bestmodel;
    uint32_t bestfit;
};


// create ransac model
// fitfun: Fit function, takes matrix_t data and fills the model into the auxilary pointer 
// distfun: Distance function, takes matrix_t data and model as auxilary pointer and fills the distances array
// modelsize: size of the fitted model parameters in bytes
// samplesize: number of samples for each iteration
// maxdistance: maximum acceptible distance of a sample to the fit model to classify a point as inlier
struct ransac_t *ransac(void (*fitfun)(matrix_t *, void *), void (*distfun)(matrix_t *, void *, float *distances), size_t modelsize, uint32_t samplesize, float maxdistance)
{
    // allocate ransac structure
    struct ransac_t *model = (struct ransac_t *)malloc(sizeof(struct ransac_t));

    // set the parameters
    model->samplesize = samplesize;
    model->maxdistance = maxdistance;
    model->modelsize = modelsize;
    model->bestfit = 0;

    model->fitfun = fitfun;
    model->distfun = distfun;

    // allocate space
    model->auxdata = calloc(1, sizeof(model->modelsize));
    model->bestmodel = calloc(1, sizeof(model->modelsize));

    return model;
}

// returns number of iterations necessary to achieve given successrate
uint32_t ransac_iteration(float iratio, uint32_t samplesize, float successrate)
{
    return log(1 - successrate) / log(1 - pow(iratio, samplesize));
}

// random sample and consensus
return_t ransac_fit(struct ransac_t *model, matrix_t *data, uint32_t numiteration)
{

    if (channels(data) != 1)
    {
        message(WARNING, "expects its arguments to be 1-dimensional matrice");
    }

    // clear the previous best
    model->bestfit = 0;

    // create matrix for partial data
    matrix_t *partial = matrix_create_(imlab_type_copy(typeof(data)), model->samplesize, cols(data), 1, NULL, 0);
    float *distances = (float*) malloc(rows(data) * sizeof(float));

    uint32_t iter = 0;
    while(iter++ < numiteration)
    {
        // create sampled data
        uint32_t s = 0;
        for(s = 0; s < model->samplesize; s++)
        {
            uint32_t r = random_int(0, rows(data) - 1);

            void *src = mdata(data, idx(data, r, 0, 0));
            void *dst = mdata(partial, idx(partial, s, 0, 0));

            // get the copy of the data
            memcpy(dst, src, cols(data) * elemsize(data));
        }

        // fit model
        model->fitfun(partial, model->auxdata);

        // test the model
        model->distfun(data, model->auxdata, distances);

        // accept or reject the model
        uint32_t fitcount = 0;
        for (s = 0; s < rows(data); s++)
        {
            fitcount += distances[s] < model->maxdistance ? 1:0;
        }

        // if the new model is the best, replace the best
        if(fitcount > model->bestfit)
        {   
            model->bestfit = fitcount;
            memcpy(model->bestmodel, model->auxdata, model->modelsize);
        }
    }
}

// get the best fitted model and return the number of inliers
int ransac_get_consensus(struct ransac_t *model, void *bestmodel)
{
    // copy the mode to the given destination
    memcpy(bestmodel, model->bestmodel, model->modelsize);

    return model->bestfit;
}

// clear the ransac model created with ransac() method
void ransac_free(struct ransac_t **model)
{
    // check the model existance
    if(model == NULL || model[0] == NULL)
    {
        return;
    }

    // clear the models
    free(model[0]->bestmodel);
    free(model[0]->auxdata);

    // set it to NULL
    model[0]->bestmodel = NULL;
    model[0]->auxdata = NULL;

    model[0]->samplesize = 0;
    model[0]->maxdistance = 0;
    model[0]->modelsize = 0;
    model[0]->bestfit = 0;
}

int main(int argc, unsigned char *argv[]) 
{
    // example data
    float noisydata0[] = {-5, 1, -3.8889, 1.4444, -2.7778, 1.8889, -1.6667, 2.3333, -0.55556, 2.7778, 0.55556, 3.2222, 1.6667, 3.6667, 2.7778, 4.1111, 3.8889, 4.5556, 5, 5};
    float noisydata1[] = {-5, 0.97868, -3.8889, 1.431, -2.7778, 1.7718, -1.6667, 2.1948, -0.55556, 2.8088, 0.55556, 3.1973, 1.6667, 3.717, 2.7778, 4.0218, 3.8889, 4.7464, 5, 5.0122};
    float noisydata2[] = {-5, 1.2094, -3.8889, 1.3991, -2.7778, 4.6206, -1.6667, 1.7027, -0.55556, 2.8889, 0.55556, 2.9982, 1.6667, 3.3601, 2.7778, 3.8915, 3.8889, 4.2724, 5, 5.0119};
    float noisydata3[] = {-5, 1.1318, -3.8889, 1.8504, -2.7778, 1.215, -1.6667, 2.0711, -0.55556, 1.0531, 0.55556, 3.3268, 1.6667, 3.7714, 2.7778, 3.8923, 3.8889, 1.2858, 5, 4.8455};

    // create data matrix
    matrix_t *data = matrix_create(float, 10, 2, 1, noisydata3);

    // fit using the whole data
    struct linear_fit_data result;
    fit(data, &result);

    // create a ransac model
    struct ransac_t *model = ransac(&fit, &distance, sizeof(struct linear_fit_data), 3, 0.2f);

    // fit line with ransac
    uint32_t iter = ransac_iteration(0.7, 10, 0.99);
    ransac_fit(model, data, iter);

    // get the best model
    struct linear_fit_data ransacresult;
    int consensus = ransac_get_consensus(model, &ransacresult);

    // print the resulting line model
    printf("Fitted line: y = %5.3fx + %5.3f\n", result.m, result.b);
    printf("Fitted line using ransac: y = %5.3fx + %5.3f\n", ransacresult.m, ransacresult.b);
    printf("Consensus[%d]: %d / %d\n", iter, consensus, rows(data));

    ransac_free(&model);

    return 0;
}