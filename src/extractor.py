import fastf1
import time
import pandas as pd

class Extractor:
    def __init__(self, start: int, end: int, modes=list):
        self.start = start
        self.end = end
        self.modes = modes
        self.limit = 100
        self.sleep_time = 5

    def _create_dataframe(self, session: fastf1.core.Session, year: int, gp: int, mode: str):
        df = session.results
        events = session.event

        df['Year'] = year
        df['GP'] = gp
        df['Mode'] = mode

        df['Country']  = events['Country']
        df['Location'] = events['Location']
        df['OfficialEventName'] = events['OfficialEventName']
        df['EventDate'] = events['EventDate']
        df['EventName'] = events['EventName']
        df['EventFormat'] = events['EventFormat']

        return df
    
    def _process_session(self, year: int, gp: int, mode: str) -> bool:
        session = fastf1.get_session(year, gp, mode)
        session._load_drivers_results()
        df = self._create_dataframe(session, year, gp, mode)

        return df
    
    def _save_dataframe(self, df: pd.DataFrame, year: int, gp: int, mode: str):
        filename = f"{year}_{gp:02}_{mode}.csv"
        df.to_csv(f"data/{filename}", index=False)
    
    def process_data(self):
        for year in range(self.start, self.end + 1):
            for mode in self.modes:
                for gp in range(1, self.limit):
                    try:
                        df = self._process_session(year, gp, mode)
                        self._save_dataframe(df, year, gp, mode)
                        time.sleep(0.45)
                    except Exception as e:
                        print(f"Error occurred while processing {year}_{gp:02}_{mode}: {e}")
                        break
            time.sleep(self.sleep_time)
