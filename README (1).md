# MySQL Car Data Analysis Project

## Overview
This project focuses on analyzing car-related data using MySQL. The dataset includes details about various car models, their manufacturers, origin countries, prices, and performance metrics.

## Dataset
The project uses a dataset containing information on cars, stored in:
- `cars.sql`: MySQL script to set up and manipulate the dataset.
- `cars_data.csv`: Contains details about car models, including manufacturer, origin, model year, average cost, and top speed.

## Database Setup
1. Import the MySQL script:
   ```sql
   SOURCE /path/to/cars.sql;
   ```
2. Verify the table structure:
   ```sql
   SHOW COLUMNS FROM cars;
   ```

## Key Data Transformations
- Created a new `cars` table as a copy of `drivearabia_all_uae`.
- Removed unnecessary columns such as `Link`, `Body Type`, `Gear box`, and `Fuel Econ (L/100km)`.

## Example Queries
### Get the Top 10 Most Expensive Cars
```sql
SELECT * FROM cars ORDER BY average_cost DESC LIMIT 10;
```

### Find Cars with Top Speed Above 300 kph
```sql
SELECT * FROM cars WHERE top_speed_kph > 300;
```

### Count Cars by Manufacturer
```sql
SELECT manufacturer, COUNT(*) AS car_count FROM cars GROUP BY manufacturer ORDER BY car_count DESC;
```

## Requirements
- MySQL Server
- Dataset (`cars.sql` and `cars_data.csv`)

## How to Contribute
Feel free to fork the repository, enhance queries, or add new analysis.

## License
This project is licensed under the MIT License.
