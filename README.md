## Bayesian Censored Regression R File for possible parallelization. 

#### History

This code is to run a Bayesian Regression. Largely, the length of time Bayesian models take to run has been a thorn
in the Psychology department's side for a while. We tend to run analyses in large datasets, and if we are running a 
Bayesian analyses on a complex regression model, analyses can take weeks to run!

I have parallelized this a little bit myself, by changing the backend of the BRM command to "cmdstanr." This allows 
for threading of the different chains (think iterations of many samples). But, if I have a large dataset (like my 
9 million x,y coordinates) and a complex model (mine is a censored gamma regression, with a complex random effect 
structure), this is not enough to make the model finish in a reasonable amount of time. The longest amount of 
time I have tried giving the model is 2 weeks, with each of my 4 BRM chains split along 10 CPU threads the whole time 
(effectively running on 40 cores). This model not finishing was quite disappointing.

So, the goal here is to get this puppy to run on a GPU. Documentation for this is out here (I have seen some mention 
of OpenCL integration), but it is beyond me (here is a good starter link https://rdrr.io/github/paul-buerkner/brms/man/opencl.html).
This would help my model here, but also MANY models run in the Psych 
Department. You are welcome to frame this as providing a solution for multiple analyses in the department if you want,
but if you want to write it up as being specific to my project, here is what my project is all about.

#### Project-specific info

For my Master's thesis, I am testing the validity of a measure of attention that can be used in online studies, as an 
analogue to webcam-based eye tracking. This method includes blurring the whole screen, except for a circular window 
of clarity that can be moved by a viewer moving their computer mouse. I had 54 participants watch 27 videos using 
this mouse blur window paradigm. They viewed these videos with different counterbalanced conditions--they received 
one of three window sizes, and one of three levels of background blur.

For this particular analysis, I am running a model to see how well window size and blur level predict how much the 
participants moved their window on a frame-to-frame basis. So, the euclidean distance between each subsequent x,y 
coordinate was calculated, and that is our dependent variable. Window size, blur level, and their interaction are 
our independent variables, and there are random slope effects of window, blur, and their interaction for each participant
(allowing for more variability between each participant). You can skip the description of the random effects if you 
want. The main idea is window and blur predicting euclidean distance. This is run as a censored gamma regression 
because he distribution of my data is similar to a gamma regression with a large spike on the left tail (there are a lot 
of 0 values). This is run as a Bayesian analyses to allow me to run a censored regression with random effects, but 
also because there is theoretical value to that analyses method itself.

#### Smaller dataset

For a smaller dataset for testing, I have reduced the data to that collected for only one video. The R code for the 
model has been adjusted to match this smaller dataset (there is no longer a random effect of video). I also reduced 
the iterations down, so the model will complete faster. More iterations are generally needed for more complex models, 
but as I have reduced the complexity, a lower number of iterations is fine.

I would try running the model as-is, making note of how long it takes to run, and then seeing if the process could 
be shortened by running the BRM command on a GPU. Then, if you really want, you can run the huge dataset as a test 
of just how powerful this fix is.

I do not know much about getting this to work on a GPU, and I do not know if the cmdstanr backend and threading will 
work on a GPU. If they cannot, the model can be run as this instead

```
model <-brm(euctrans| cens(censored)~ TRIAL_blurCondition.c * TRIAL_windowCondition.c + (TRIAL_blurCondition.c * TRIAL_windowCondition.c|participant), family=Gamma(link="log"),
           data=myd, init="0", iter=6000, chains = 4, cores = 4, warmup = 1000, prior = priors2, save_pars=save_pars(all=TRUE))
```

If you have any questions, email me at karipayne@ksu.edu.

Thanks!
