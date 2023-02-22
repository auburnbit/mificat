
def sm_2(user_grade, rep_number, easiness, interval):
    
    if user_grade >= 3:
        if rep_number == 0:
            interval = 1
        elif rep_number == 1:
            interval = 6
        else:
            interval = int(interval * easiness)
        rep_number += 1
    else:         
        rep_number = 0
        interval = 1        

    easiness += 0.1 - (5 - user_grade) * (0.08 + (5 - user_grade) * 0.02)
    if easiness < 1.3:
        easiness = 1.3
            
    return (rep_number, easiness, interval)

def quiz_result():
    return "correct"