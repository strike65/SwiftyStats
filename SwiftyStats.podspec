Pod::Spec.new do |s|
	s.name 		= 'SwiftyStats'
	s.version 	= '1.1.6'
	s.summary 	= 'Descriptive Statistics, Probability Functions (PDF, CDF, iCDF), parametric and nonparametric tests'
	s.description 	= <<-DESC
Includes (list is not exhaustive):
Descriptive Statistics
- sample size
- length (= number of unique elements)
- frequencies (absolute, relative, cumulative)
- empirical cdf
- means (arithmetic, geometric, harmonic, contraharmonic)
- empirical dispersion measures (variance, semi variance, standard deviation, standard error)
- empirical moments (central, about the origin, standardized)
- entropy based measures
- mode
- maximum, minimum
- quantiles
- Box-and-Whisker statistics
- outliers
- ...

Hypothesis Testing
- Kolmogorov Smirnov test (one/two sample))
- Anderson Darling test
- Bartlett test
- Levene test (with variants)
- Grubbs test
- ESD test (Rosner test)
- t test (matched, 2-sample)
- Mann Whitney U-test
- Wilcoxon matched pairs test
- sign test
- one factor ANOVA
- Tukey-Kramer post hoc test
- Scheffé test
- Chi^2 test
- F test
- runs test
- ...

Probability functions
- Normal Distribution
- F-Ratio Distribution
- Student's T Distribution
- noncentral T Distribution
- Chi^2 Distribution
- noncentral Chi^2 Distribution
- Beta Distribution
- Gamma Distribution
- Log Normal Distribution
- Cauchy Distribution
- Laplace Distribution
- Pareto Distribution
- Wald Distribution
- Exponential Distribution
- Uniform Distribution
- Triangular Distribution
- Rayleigh distribution
- Extreme value distribution
DESC
	s.homepage 	= 'https://github.com/strike65/SwiftyStats.git'
	s.license 	= { :type => 'GPL 3', :file => 'LICENSE' }
	s.author 	= { 'strike65' => 'vtping@me.com' }
	s.source 	= { :git => 'https://github.com/strike65/SwiftyStats.git', :tag => s.version.to_s }
	s.swift_version = '5.0'
	s.ios.deployment_target = '13.0'
	s.osx.deployment_target = '10.12'
  s.source_files 	= 'SwiftyStats/CommonSource/**/*.swift'
end

