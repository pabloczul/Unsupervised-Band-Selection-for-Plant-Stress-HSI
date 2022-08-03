def bands_separation(bands, datasetX, datasetY):
    
    #Read data
    data_X = datasetX
    data_Y = datasetY
    
    data_X_selected = data_X[:,:,bands]

    print(data_X_selected.shape)

    #data dimensions
    x, y, z = data_X_selected.shape

    #reshapes arrays to have all data of each matrix into vectors
    data_X2d = data_X_selected.reshape((x * y, z))
    data_Y2d = data_Y.reshape((x * y, 1))

def extract_pixels(X, y):
    q = X.reshape(-1, X.shape[2])
    df = pd.DataFrame(data = q)
    df = pd.concat([df, pd.DataFrame(data = y.ravel())], axis=1)
    df.columns= [f'band{i}' for i in range(1, 1+X.shape[2])]+['class']
    #df.to_csv('Dataset.csv')
    return df

def confussion(test, predict, class_names):
    """Creates a dataframe for the confusion matrix between test and predict, using class_names dictionary as tags"""
    # Deleting zeros of dataset. zeros are non class
    inter = np.intersect1d(np.where(test.flat!=0)[0], np.where(predict.flat!=0)[0])

    cmatrix = metrics.confusion_matrix(test.reshape(-1)[inter], predict.reshape(-1)[inter])
    #cmatrix = np.round(cmatrix/cmatrix.max(), 2)

    confusion_dataframe = pd.DataFrame(cmatrix, index=np.array(class_names), columns=np.array(class_names))

    return confusion_dataframe