import csv
from pathlib import Path
import tempfile
import unittest

from compare_features import COLUMNS, compare


class ScientificComparison(unittest.TestCase):
    def test_altered_mass_missing_row_and_nonfinite_values_fail(self):
        with tempfile.TemporaryDirectory() as directory:
            reference, actual = [Path(directory)/name for name in ('expected.tsv', 'actual.tsv')]
            row = dict.fromkeys(COLUMNS, '1')
            def write(path, rows):
                with path.open('w', newline='') as stream:
                    writer = csv.DictWriter(stream, fieldnames=COLUMNS, delimiter='\t')
                    writer.writeheader()
                    writer.writerows(rows)
            write(reference, [row])
            write(actual, [row])
            compare(actual, reference)
            for rows in ([], [{**row, 'MonoisotopicMass': '2'}], [{**row, 'SumIntensity': 'nan'}]):
                write(actual, rows)
                with self.assertRaises(ValueError):
                    compare(actual, reference)


if __name__ == '__main__':
    unittest.main()
