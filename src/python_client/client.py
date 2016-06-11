import dbUtil

db = dbUtil.getDefaultDatabase();

while True:
	experimentId = db.getNextExperiment()
	if experimentId is not None:
		print(experimentId)
		experimentParams = db.getExperimentParams(experimentId)
		experimentScript = db.getExperimentScript(experimentId)

		exec experimentScript #creates function called runExperiment(experimentParams)		
		score, detail = runExperiment(experimentParams)
		db.recordExperimentResult(experimentId, score, detail)
	else:
		print('no work to do')
		break
