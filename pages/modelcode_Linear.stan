
data{                  // data block
  int N;                  // total number of subjects
  array[N] real dose;     // dose
  array[N] real y;        // response
}
parameters{            // parameter block
  real<lower=0> sigma;    // homogenous error across dose
  real beta0;             // background response
  real<lower=0> beta1;            // slope
}
transformed parameters{  // transformed parameter block
  array[N] real mu;           // store expected response as an intermediate variable
  for(n in 1:N){
    mu[n] = beta0+beta1 * dose[n];    // linear dose response  function
  }
}
model{                  // model block
  // priors                 // specify prior distributions
  beta0 ~ normal(0,10);
  beta1 ~ normal(0,5); // truncation at zero specified in the parameter block
  sigma ~ student_t(3, 0, 2.5);      // same prior distributions as brms
  // model              // specify likelihood function
  y ~ normal(mu,sigma);     
}
generated quantities{   // generate quantities for other uses
  array[N] real log_lik;    // log likelihood for elpd computation
  array[N] real y_pred;     // posterior predicted values
  for(n in 1:N){
    log_lik[n] = normal_lpdf(y[n] | mu[n],sigma);
    y_pred[n] = normal_rng(mu[n],sigma);
  }
}


