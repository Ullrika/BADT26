data {
  int<lower=1> n;  // total number of observations
  array[n] int r;  // response variable
  array[n] int N;  // number of trials
  array[n] int x;  // population-level design matrix
  int<lower=1> K;  // number of grouping levels
  array[n] int<lower=1> g;  // grouping indicator per observation
  array[K] real q; // quality terms
  vector[2] hyper_sigma; // hyper parameters for sigma prior
  vector[2] hyper_mu; // hyper parameters for mu prior
  vector[2] hyper_eta; // hyper parameters for eta prior
}
parameters {
  real mu; // overall log hazard ratio
  real<lower=0> sigma; // between study variation in log hazard ratio
  vector[K] eta; // study specfic average log cumulative hazard between the two interventions
  vector[K] delta; // study specific difference in log cumulative hazards of the two interventions
}

model {
    matrix[K,2] theta; // binomial parameter for each intervention and study
  
  // prior
  to_vector(eta) ~ normal(hyper_eta[1],hyper_eta[2]);
  mu ~ normal(hyper_mu[1],hyper_mu[2]); 
  sigma ~ normal(hyper_sigma[1],hyper_sigma[2]) T[0,]; // informed prior similar to normal(0.2,0.05);
  
  // random effects
  for (j in 1:K) {
    delta[j] ~ normal(mu,sigma/q[j]);
    theta[j,1] = 1-exp(-exp(eta[j] - delta[j]/2));
    theta[j,2] = 1-exp(-exp(eta[j] + delta[j]/2));
  }
  

  // likelihood
    for (id in 1:n) {
      r[id] ~ binomial(N[id],theta[g[id],x[id]]); // observations
    }
}

generated quantities {
  real HR; // overall hazard ratio
  HR = exp(mu);
}




