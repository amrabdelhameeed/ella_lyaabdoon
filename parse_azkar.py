import re

with open('lib/core/constants/app_lists.dart', 'r', encoding='utf-8') as f:
    content = f.read()

def extract_block(text, start_pattern, end_pattern):
    match_start = re.search(start_pattern, text)
    if not match_start: return None, 0, 0
    start_idx = match_start.end()
    
    match_end = re.search(end_pattern, text[start_idx:])
    if not match_end: return None, 0, 0
    end_idx = start_idx + match_end.start()
    
    return text[start_idx:end_idx], match_start.end(), start_idx + match_end.start()

# Find the start and end of each period's rewards array
fajr_match = re.search(r"period: AzanDayPeriod\.fajr,\s*rewards:\s*const\s*\[", content)
fajr_start = fajr_match.end()
fajr_end = content.find("],", fajr_start)

shorouq_match = re.search(r"period: AzanDayPeriod\.shorouq,\s*rewards:\s*const\s*\[", content)
shorouq_start = shorouq_match.end()
shorouq_end = content.find("],", shorouq_start)

duhr_match = re.search(r"period: AzanDayPeriod\.duhr,\s*rewards:\s*const\s*\[", content)
duhr_start = duhr_match.end()
duhr_end = content.find("],", duhr_start)

asr_match = re.search(r"period: AzanDayPeriod\.asr,\s*rewards:\s*const\s*\[", content)
asr_start = asr_match.end()
asr_end = content.find("],", asr_start)

maghrib_match = re.search(r"period: AzanDayPeriod\.maghrib,\s*rewards:\s*const\s*\[", content)
maghrib_start = maghrib_match.end()
maghrib_end = content.find("],", maghrib_start)

isha_match = re.search(r"period: AzanDayPeriod\.isha,\s*rewards:\s*const\s*\[", content)
isha_start = isha_match.end()
isha_end = content.find("],", isha_start)

night_match = re.search(r"period: AzanDayPeriod\.night,\s*rewards:\s*const\s*\[", content)
night_start = night_match.end()
night_end = content.find("],", night_start)

# We want to extract morning azkar from shorouq (first 19 rewards or so). 
# Actually, it's easier to just do it via string replacement of the specific items.
# Or better: let me generate the new file by keeping the structure but replacing the arrays.
print("Parsed all blocks.")
