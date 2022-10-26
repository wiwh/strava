import pandas as pd

def streams2df(streams):
    st = {series['type']:series['data'] for series in streams}
    df = pd.DataFrame.from_dict(st)
    return(df)



def all_streams2df(all_streams):
  all_df = []
  while all_streams:
    record = all_streams.pop()
    if type(record['activity_streams']) is dict:
      # there was an error in the query
      continue
    new_df = streams2df(record['activity_streams'])
    if (record['activity_id'] == 575806413):
      print("haha")
    new_df.insert(0, "activity_id", record['activity_id'])
    all_df.append(new_df)
  df = pd.concat(all_df, ignore_index=True)
  
  return(df)
