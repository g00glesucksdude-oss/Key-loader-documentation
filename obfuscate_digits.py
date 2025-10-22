# Fixed mapping: digits 0–9 → complex CJK symbols
CJK_MAP = {
    '0': '齉',  # Chinese
    '1': '鬱',
    '2': '龘',
    '3': '麤',
    '4': '飍',
    '5': '灥',
    '6': '纞',
    '7': '鱻',
    '8': '黷',
    '9': '癵'
}

# Reverse map for de-obfuscation
REVERSE_CJK_MAP = {v: k for k, v in CJK_MAP.items()}

def obfuscate_digits(input_digits):
    return ''.join(CJK_MAP[d] for d in input_digits)

def restore_digits(obfuscated_string):
    return ''.join(REVERSE_CJK_MAP[c] for c in obfuscated_string)

# Example usage
original = "1234567890"
obfuscated = obfuscate_digits(original)
restored = restore_digits(obfuscated)

print("Original:", original)
print("Obfuscated:", obfuscated)
print("Restored:", restored)
