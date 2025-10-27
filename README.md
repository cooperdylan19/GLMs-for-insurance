<h1 align="center">From Petals to Premiums: Practical GLM Applications in R</h1>

<p align="justify">
<b>Abstract</b>: Introduced in 1972, Generalised Linear Models (GLMs) have since found wide use across science and industry, from identifying plant species and analysing medical outcomes to modelling financial risk and determining insurance premiums. While standard linear models often suffice, many datasets deviate from normality, reducing their effectiveness. GLMs extend this framework by allowing a wider range of probability distributions, enhancing both flexibility and applicability. Here, the presence of <i>versicolour</i> is modelled from morphological traits using a binomial distribution. The approach is then applied to medical insurance data, employing the industry-standard Tweedie distribution to capture the skewed nature of premium values. Initially, a simple model is fitted, excluding variable interactions and using a fixed power parameter. Model accuracy is assessed using the mean absolute error (MAE) and root mean square error (RMSE). A more advanced model is then developed, incorporating interaction terms and optimising the power parameter through a grid search. Model performance improves markedly, with the mean absolute error decreasing from 6320 to 4671 and the root mean square error from 3745 to 2792. The power parameter shifts from 1.67 to 1.34.
</p>


### Binomial GLM Predictions for Versicolour

<p align="justify">
This script (GLMsinR_flowers) constructs and evaluates a series of GLMs to predict the likelihood of an iris specimen belonging to the versicolour species based on its morphological features. The dataset is first modified to express versicolour as a binary variable, after which 3 binomial GLMs are fitted with increasing model complexity. 

**Model 1** *m_base*: contains only an intercept and no predictor variables. <br />
**Model 2** *m*: introduces Sepal Length and Sepal Width as predictors. <br />
**Model 3** *m2*: incorporates all four morphological features of the iris dataset: sepal and petal length and width.
  
| Model | Residual Deviance | ΔDeviance | p-value | Interpretation |
|:------|:-----------------:|:---------:|:-------:|:---------------|
| **m_base** | 190.95 | — | — | Baseline model with no predictors |
| **m** | 151.65 | 39.30 | < 0.001 | Significant improvement over baseline |
| **m2** | 145.07 | 6.58 | 0.037 | Further significant improvement; best overall model |


This code produces a set of predicted probability plots showing how each morphological feature influences the likelihood that an iris specimen belongs to the versicolour species, according to the fitted binomial GLM (m2 - model with best accuracy). In each plot, the x-axis represents the observed range of that predictor, while the y-axis shows the predicted probability of versicolour membership estimated by the model. The magenta line indicates the model’s fitted relationship, and the shaded band around it shows the 95% confidence interval.


### Tweedie GLM Predictions for medical premiums

#### Basic model (no variable interactions)

#### Advanced model (variable interactions)
