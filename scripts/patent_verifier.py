#!/usr/bin/env -S uv run
# /// script
# requires-python = ">=3.11"
# ///
"""
Script to calculate verification code for Argentine vehicle license plates.
Usage:
    patent_verifier.py <patent>
    patent_verifier.py AG428AH
    echo "AG428AH" | patent_verifier.py
"""
import sys
from typing import Dict


class PatentVerifier:
    """Calculator for Argentine vehicle license plate verification codes."""

    # Letter to number equivalence table
    CONVERSION_TABLE: Dict[str, str] = {
        'A': '14', 'B': '01', 'C': '00', 'D': '16', 'E': '05', 'F': '20',
        'G': '19', 'H': '09', 'I': '24', 'J': '07', 'K': '21', 'L': '08',
        'M': '04', 'N': '13', 'O': '25', 'P': '22', 'Q': '18', 'R': '10',
        'S': '02', 'T': '06', 'U': '12', 'V': '23', 'W': '11', 'X': '03',
        'Y': '15', 'Z': '17'
    }

    def __init__(self, patent: str):
        """
        Initialize the verifier with a patent number.

        Args:
            patent: The license plate string (e.g., "AG428AH")
        """
        self.patent = patent.upper().replace(" ", "")
        self.numeric_sequence = self._convert_to_numeric()

    def _convert_to_numeric(self) -> str:
        """
        Convert letters in the patent to their numeric equivalents.

        Returns:
            String with all characters converted to numbers
        """
        result = ""
        for char in self.patent:
            if char.isalpha():
                result += self.CONVERSION_TABLE.get(char, "")
            else:
                result += char
        return result

    def _reduce_to_single_digit(self, number: int) -> int:
        """
        Reduce a number to a single digit by summing its digits recursively.

        Args:
            number: The number to reduce

        Returns:
            Single digit result
        """
        while number >= 10:
            number = sum(int(digit) for digit in str(number))
        return number

    def calculate(self) -> str:
        """
        Calculate the two-digit verification code.

        The algorithm:
        1. Convert letters to numbers using the conversion table
        2. Split digits into two groups (alternating from right to left)
        3. Sum each group separately
        4. Reduce each sum to a single digit
        5. Concatenate the two digits

        Returns:
            Two-digit verification code as string
        """
        # Split digits into alternating groups (right to left)
        reversed_seq = self.numeric_sequence[::-1]

        # Group 1: positions 0, 2, 4... (from right)
        # Group 2: positions 1, 3, 5... (from right)
        group1 = [int(d) for d in reversed_seq[::2]]
        group2 = [int(d) for d in reversed_seq[1::2]]

        sum1 = sum(group1)
        sum2 = sum(group2)

        digit1 = self._reduce_to_single_digit(sum1)
        digit2 = self._reduce_to_single_digit(sum2)

        return f"{digit1}{digit2}"


def main():
    """Main execution function."""
    try:
        # Read from argument or stdin
        if len(sys.argv) < 2:
            if sys.stdin.isatty():
                print("Usage: patent_verifier.py <patent>")
                print("       echo 'AG428AH' | patent_verifier.py")
                print("\nExamples:")
                print("  patent_verifier.py AG428AH")
                print("  patent_verifier.py 'AB 123 CD'")
                sys.exit(1)

            patent = sys.stdin.read().strip()
        else:
            patent = sys.argv[1]

        if not patent:
            print("✗ Error: Empty patent provided")
            sys.exit(1)

        verifier = PatentVerifier(patent)
        verification_code = verifier.calculate()

        print(f"Patent: {verifier.patent}")
        print(f"Verification code: {verification_code}")

    except Exception as e:
        print(f"✗ Error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
