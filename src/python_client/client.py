import pg8000
import databaseUtil

conn = getDefaultConnection()

while True:
	experimentId = getNextExperiment()
	
	if experimentId is not None:
		experimentParams = getExperimentParams(experimentId)
		experimentScript = getExperimentScript(experimentId)
		exec experimentScript #creates function called runExperiment(experimentParams)
		score, detail = runExperiment(experimentParams)
		recordResult(experimentId, score, detail)
	else:
		break
