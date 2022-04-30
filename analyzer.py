import re
import pandas as pd
import os


def analyze_file(bdw, error_rate, index):
    simulate_time = 100
    rcv_count = 0
    send_count = 0
    packet_sum = 0
    start_times = {}
    delay_sum = 0
    file_name = f'{base_epoch_name}_{index}_{bdw}/rts-data-ack.tr'
    ptr = 0
    throughput = 0
    delay = 0
    with open(file_name, 'r') as f:
        lines = f.read().split('\n')
        for line in lines:
            logs = re.split(' |\t', line)
            if logs[0] == 's' and (logs[2] == '_1_' or logs[2] == '_2_') and logs[3] == 'AGT' and logs[7] == 'cbr':
                send_count += 1
                start_times[logs[6]] = float(logs[1])
            elif logs[0] == 'r' and (logs[2] == '_7_' or logs[2] == '_8_') and logs[3] == 'AGT' and logs[7] == 'cbr':
                rcv_count += 1
                packet_sum += float(logs[8])
                delay_sum += float(logs[1]) - start_times[logs[6]]
        throughput = packet_sum / simulate_time
        ptr = rcv_count / send_count
        delay = delay_sum / rcv_count
    return throughput, ptr, delay


if __name__ == '__main__':
    base_epoch_name = 'epoch'
    bandwidths = [1.5, 55, 155]
    error_rates = [0.001, 0.002, 0.003, 0.004, 0.005, 0.006, 0.007, 0.008, 0.009, 0.01]
    data = []

    for bdw in bandwidths:
        for i in range(len(error_rates)):
            throughput, ptr, delay = analyze_file(bdw, error_rates[i], i)
            data.append({
                'bandwidth': bdw,
                'error_rate': error_rates[i],
                'throughput': throughput,
                'ptr': ptr,
                'delay': delay
            })

    df = pd.DataFrame(data)
    df.to_csv(f'analyzer_result.csv', index=False, columns=['bandwidth', 'error_rate', 'throughput', 'ptr', 'delay'])
    print(df)
