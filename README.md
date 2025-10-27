<h1 align="center">From Petals to Premiums: Practical GLM Applications in R</h1>

<p align="justify">
<b>Abstract</b>: Introduced in 1972, Generalised Linear Models (GLMs) have since found wide use across science and industry, from identifying plant species and analysing medical outcomes to modelling financial risk and determining insurance premiums. While standard linear models often suffice, many datasets deviate from normality, reducing their effectiveness. GLMs extend this framework by allowing a wider range of probability distributions, enhancing both flexibility and applicability. Here, the presence of <i>versicolour</i> is modelled from morphological traits using a binomial distribution. The approach is then applied to medical insurance data, employing the industry-standard Tweedie distribution to capture the skewed nature of premium values. Initially, a simple model is fitted, excluding variable interactions and using a fixed power parameter. Model accuracy is assessed using the mean absolute error (MAE) and root mean square error (RMSE). A more advanced model is then developed, incorporating interaction terms and optimising the power parameter through a grid search. Model performance improves markedly, with the mean absolute error decreasing from 6320 to 4671 and the root mean square error from 3745 to 2792. The power parameter shifts from 1.67 to 1.34.
</p>


### Binomial GLM Predictions for Versicolour

<p align="justify">
This script constructs and evaluates a series of Generalised Linear Models (GLMs) to predict the likelihood of an iris specimen belonging to the versicolour species based on its morphological features. The dataset is first modified to express versicolour as a binary variable, after which several binomial GLMs are fitted with increasing model complexity. Statistical summaries and model comparisons are generated to assess predictor significance and overall fit. Predicted probabilities with 95% confidence intervals are then visualised across key variables, arranged into a composite grid of plots. The resulting figure is shown below.
</p>

![fig1](/iris_glm_plots.pdf)
