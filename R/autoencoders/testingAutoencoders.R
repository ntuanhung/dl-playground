#install.packages("autoencoder")


## Train the autoencoder on unlabeled set of 5000 image patches of 
## size Nx.patch by Ny.patch, randomly cropped from 10 nature photos:
## Load a training matrix with rows corresponding to training examples, 
## and columns corresponding to input channels (e.g., pixels in images):
library(autoencoder)
data('training_matrix_N=5e3_Ninput=100')
dim(training.matrix) #5000 x 100
N = 10
for (i in 1:10) {
  image(matrix(training.matrix[i,], nrow = N, ncol = N), useRaster = TRUE,axes = FALSE, col=gray((0:255)/255))
}

# Rest is simply taken from the help function
nl=3                          ## number of layers (default is 3: input, hidden, output)
unit.type = "logistic"        ## specify the network unit type, i.e., the unit's 
## activation function ("logistic" or "tanh")
Nx.patch=10                   ## width of training image patches, in pixels
Ny.patch=10                   ## height of training image patches, in pixels
N.input = Nx.patch*Ny.patch   ## number of units (neurons) in the input layer (one unit per pixel)
N.hidden = 10*10                ## number of units in the hidden layer
lambda = 0.0002               ## weight decay parameter     
beta = 6                      ## weight of sparsity penalty term 
rho = 0.01                    ## desired sparsity parameter
epsilon <- 0.001              ## a small parameter for initialization of weights 
## as small gaussian random numbers sampled from N(0,epsilon^2)
max.iterations = 2000         ## number of iterations in optimizer


if (FALSE) {
  ## Train the autoencoder on training.matrix using BFGS optimization method 
  ## (see help('optim') for details):
  ## WARNING: the training can take a long time (~1 hour) for this dataset!
  autoencoder.object <- autoencode(X.train=training.matrix,nl=nl,N.hidden=N.hidden,
                                 unit.type=unit.type,lambda=lambda,beta=beta,rho=rho,epsilon=epsilon,
                                 optim.method="BFGS",max.iterations=max.iterations,
                                 rescale.flag=TRUE,rescaling.offset=0.001)
  ## N.B.: Training this autoencoder takes a long time, so in this example we do not run the above 
  ## autoencode function, but instead load the corresponding pre-trained autoencoder.object.
  save(autoencoder.object, file = "autoencoder.object.rnd")
} else {
  load("autoencoder.object.rnd")
}

## Report mean squared error for training and test sets:
cat("autoencode(): mean squared error for training set: ", round(autoencoder.object$mean.error.training.set,3),"\n")
#########################
# Inspektion des Resultats
visualize.hidden.units(autoencoder.object,Nx.patch,Ny.patch)

## Extract weights W and biases b from autoencoder.object:
Wall <- autoencoder.object$W
ball <- autoencoder.object$b
## Visualize hidden units' learned features:
str(Wall) #Wir haben zwei Layer
W = Wall[[1]] #Die Gewichte des ersten Layers
str(W)
for (i in 1:10) {
  x_max = W[i,] / sqrt(sum(W[i,]^2))
  cat('Sum of all pixels',sum(x_max^2), '\n')
  image(matrix(x_max, ncol = 10), useRaster = TRUE,axes = FALSE, col=gray((0:255)/255))
}








