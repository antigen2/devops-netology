#!/usr/bin/env python3

import os
import datetime
import json
import subprocess


PROC_PATH = '/proc'
# LOG_PATH = os.path.join(os.environ['HOME'], 'monitoring')
LOG_PATH = '/var/log'
LOG_FILE_TEMPLATE = '-awesome-monitoring.log'


def get_pid_list() -> list:
    """
    Getting PIDs
    :return: PID list
    """
    res = []
    for s in os.listdir(PROC_PATH):
        if os.path.isdir(f'{PROC_PATH}/{s}') and s.isdigit():
            res.append(int(s))
    return res


def get_port_list() -> list:
    """
    Getting open ports
    :return: ports list
    """
    res = []
    cmd = subprocess.run(['ss', '-antuH'], capture_output=True, text=True)
    for line in cmd.stdout.splitlines():
        proc_list = line.split()
        proc_dict = dict()
        proc_dict['type'] = proc_list[0]
        proc_dict['state'] = proc_list[1]
        proc_dict['local'] = proc_list[4]
        proc_dict['peer'] = proc_list[5]
        res.append(proc_dict)
    return res


def get_params(file_name: str) -> list:
    """
    Getting parameters list from file
    :param file_name: file name
    :return: parameters list
    """
    f_name = os.path.join(PROC_PATH, file_name)
    with open(f_name, 'r') as f:
        return f.read().split()


def get_load_cpu() -> dict:
    """
    Getting loadavg
    :return: dict of cpu loadavg
    """
    plist = get_params('loadavg')
    return dict(load_now=plist[0], load_5m=plist[1], load_15m=plist[2], threads=plist[3])


def get_uptime() -> dict:
    """
    Getting uptime
    :return: dict of uptime
    """
    plist = get_params("uptime")
    return dict(up_time=plist[0], idle_time=plist[1])


if __name__ == '__main__':

    # if not os.path.exists(LOG_PATH):
    #     os.makedirs(LOG_PATH)

    log = dict()
    log['timestamp'] = int(datetime.datetime.now().timestamp())
    log['pid_list'] = get_pid_list()
    log['ports'] = get_port_list()
    log['loadavg'] = get_load_cpu()
    log['uptime'] = get_uptime()

    _date = datetime.datetime.now().strftime('%y-%m-%d')

    f_name = os.path.join(LOG_PATH, f'{_date}{LOG_FILE_TEMPLATE}')
    with open(f_name, 'a') as f:
        f.write(json.dumps(log)+'\n')
