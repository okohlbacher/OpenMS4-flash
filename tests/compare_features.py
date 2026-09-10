#!/usr/bin/env python3
"""Compare numerical output against the independently run pre-refactor Core."""
import csv
import math
from pathlib import Path
import sys

# Filenames and row IDs do not change numerical equivalence.
COLUMNS = (
    'MSLevel', 'MonoisotopicMass', 'AverageMass', 'MassCount', 'StartRetentionTime',
    'EndRetentionTime', 'RetentionTimeDuration', 'ApexRetentionTime',
    'SumIntensity', 'MaxIntensity', 'FeatureQuantity', 'MinCharge', 'MaxCharge',
    'ChargeCount', 'IsotopeCosineScore', 'Qscore2D', 'PerChargeIntensity', 'PerIsotopeIntensity',
)


def compare(actual, reference):
    def read(path):
        with Path(path).open(newline='') as stream:
            reader = csv.DictReader(stream, delimiter='\t')
            if not set(COLUMNS).issubset(reader.fieldnames or []):
                raise ValueError(f'Missing scientific columns: {path}')
            return list(reader)
    observed, expected = read(actual), read(reference)
    if not expected or len(observed) != len(expected):
        raise ValueError('Feature row count differs from the nonempty reference')
    for index, (left, right) in enumerate(zip(observed, expected)):
        for column in COLUMNS:
            values = [float(value) for value in left[column].split(';')]
            targets = [float(value) for value in right[column].split(';')]
            if len(values) != len(targets):
                raise ValueError(f'Row {index}, {column}: array length differs')
            # Mass values are printed to six decimals; intensities to six digits.
            relative = 0.0 if column in ('MonoisotopicMass', 'AverageMass') else 1e-5
            for value, target in zip(values, targets):
                if not math.isfinite(value) or not math.isfinite(target) or not math.isclose(
                        value, target, rel_tol=relative, abs_tol=2e-6):
                    raise ValueError(f'Row {index}, {column}: {value} != {target}')


if __name__ == '__main__':
    compare(*sys.argv[1:])
