import pandas as pd
import os

csv_path = r'C:\Users\ivan-\Documents\GitHub\Trabajo-Terminal\flowdiagramapp\docs\ccCronograma_FlowCode_TT_2026-A038.csv'
excel_path = r'C:\Users\ivan-\Documents\GitHub\Trabajo-Terminal\flowdiagramapp\docs\ccCronograma_FlowCode_TT_2026-A038.xlsx'

def fix_line(line, expected_cols):
    parts = line.strip().split(',')
    if len(parts) <= expected_cols:
        # Pad with empty strings if too few (shouldn't happen based on analysis)
        return parts + [''] * (expected_cols - len(parts))
    else:
        # Merge extra parts into the first column
        first_col = ",".join(parts[:len(parts) - (expected_cols - 1)])
        remaining = parts[len(parts) - (expected_cols - 1):]
        return [first_col] + remaining

all_data = []
current_section = 1

try:
    with open(csv_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
except UnicodeDecodeError:
    with open(csv_path, 'r', encoding='latin-1') as f:
        lines = f.readlines()

for i, line in enumerate(lines):
    # Detect transition to Section 2
    if "Segundo Semestre" in line:
        current_section = 2
        # Add an empty row for separation if not the first row
        if all_data:
            all_data.append([''] * 25) 
    
    if current_section == 1:
        fixed = fix_line(line, 25)
        # Pad to 25 if needed (already done in fix_line)
        all_data.append(fixed)
    else:
        fixed = fix_line(line, 21)
        # Pad with empty strings to match the 25-column width of the sheet if desired,
        # or just keep it as is. Let's pad to 25 for consistency in the dataframe.
        padded = fixed + [''] * (25 - 21)
        all_data.append(padded)

df = pd.DataFrame(all_data)

# Create Excel writer
with pd.ExcelWriter(excel_path, engine='openpyxl') as writer:
    df.to_excel(writer, index=False, header=False, sheet_name='Cronograma')

print(f"Excel file created at: {excel_path}")
