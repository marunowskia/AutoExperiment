import dbUtil

db = dbUtil.getDefaultDatabase()
assert db.getNextExperiment()
print('minimal tests passed')
