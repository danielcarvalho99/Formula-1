import fastf1

class Extractor:
    def __init__(self, years=list, modes=list):
        self.years = years
        self.modes = modes
        self.limit = 100

    def extract_results(self, year: int, gp: int, mode: str):
        session = fastf1.get_session(year, gp, mode)
        session._load_drivers_results()
        return session.results
    
    def save_data(self, df, year: int, gp: int, mode: str):
        df['Year'] = year
        df['GP'] = gp
        df['Mode'] = mode
        df.to_csv(f"data/{year}_{gp:02}_{mode}.csv", index=False)
        
        return None

    def process_data(self, year: int, gp: int, mode: str) -> bool:
        df = self.extract_results(year, gp, mode)
        self.save_data(df, year, gp, mode)
        return True
    
    def process_year_mode(self, year: int, mode: str):
        for i in range(1, self.limit):
            try:
                self.process_data(year, i, mode)
            except Exception as e:
                break
        
        return None
