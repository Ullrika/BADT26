

data {
  int<lower=1> n;  // total number of observations
  array[n] int r;  // response variable
  array[n] int N;  // number of trials
  array[n] int x;  // population-level design matrix
  int<lower=1> K;  // number of grouping levels
  array[n] int<lower=1> g;  // grouping indicator per observation
  array[K] real q; // quality terms
  vector[2] hyper_sigma; // hyper parameters for sigma prior
}
parameters {
  matrix<lower=0,upper=1>[K,2] theta;  // 
  real<lower=0> sigma;
}
transformed parameters {
  matrix[K,2] logH; // cumulative hazard
  logH = log(-log(1-theta));
  vector[K] logHR; // hazard ratio
  logHR = logH[,1] - logH[,2];
  real avlogHR; // average of hazard ratios
  avlogHR = mean(logHR); 
}
model {
  // prior
  to_vector(theta) ~ beta(1,1);
  sigma ~ normal(hyper_sigma[1],hyper_sigma[2]); // gamma(14,70); // informed prior similar to normal(0.2,0.05);
  
  // likelihood
    for (id in 1:n) {
      r[id] ~ binomial(N[id],theta[g[id],x[id]]); // observations
    }
    for (j in 1:K) {
      logHR ~ normal(avlogHR, sigma/q[j]); // random effects
    }
}
generated quantities {
  real HR; // hazard ratio
  HR = exp(avlogHR); 
}


