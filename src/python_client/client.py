import dbUtil

db = dbUtil.getDefaultDb();

while True:
	experimentId = db.getNextExperiment()
	if experimentId is not None:
		experimentParams = db.getExperimentParams(experimentId)
		experimentScript = db.getExperimentScript(experimentId)
		exec experimentScript #creates function called runExperiment(experimentParams)
		score, detail = runExperiment(experimentParams)
		db.recordResult(experimentId, score, detail)
	else:
		break
