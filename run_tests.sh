#!/bin/sh
# Define connection parameters for normalized and denormalized databases.
NORMS_HOST=localhost
NORMS_PORT=9002
NORMS_DB=postgres
NORMS_USER=postgres
NORMS_PASSWORD=pass

DENORM_HOST=localhost
DENORM_PORT=9001
DENORM_DB=postgres
DENORM_USER=postgres
DENORM_PASSWORD=pass

# Temporary files to store outputs.
NORM_OUTPUT="norm_output.txt"
DENORM_OUTPUT="denorm_output.txt"

# Loop through each SQL file in the sql folder.
for sqlfile in sql/*.sql; do
    echo "Running test: $sqlfile on normalized database..."
    PGHOST=$NORMS_HOST PGPORT=$NORMS_PORT PGDATABASE=$NORMS_DB PGUSER=$NORMS_USER PGPASSWORD=$NORMS_PASSWORD \
      psql -f "$sqlfile" > "$NORM_OUTPUT" 2>&1

    echo "Running test: $sqlfile on denormalized database..."
    PGHOST=$DENORM_HOST PGPORT=$DENORM_PORT PGDATABASE=$DENORM_DB PGUSER=$DENORM_USER PGPASSWORD=$DENORM_PASSWORD \
      psql -f "$sqlfile" > "$DENORM_OUTPUT" 2>&1

    # Compare the outputs.
    if diff -B "$NORM_OUTPUT" "$DENORM_OUTPUT" > /dev/null; then
        echo "PASS: $sqlfile results match."
    else
        echo "FAIL: $sqlfile results differ!"
        echo "Differences:"
        diff -B "$NORM_OUTPUT" "$DENORM_OUTPUT"
    fi
    echo "---------------------------------------"
done

# Clean up temporary files.
rm -f "$NORM_OUTPUT" "$DENORM_OUTPUT"
