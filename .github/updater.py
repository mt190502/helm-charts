#!/usr/bin/env python3
from packaging.version import Version, InvalidVersion

import re
import requests
import os
import yaml

current_directory = os.getcwd()
repository = os.environ['GITHUB_REPOSITORY']


def compare_versions(current, latest):
    if current['maj'] < latest['maj']:
        return 'upgrade-major'
    elif current['maj'] > latest['maj']:
        return 'downgrade-major'
    elif (current['min'] < latest['min']) or (current['min'] == latest['min'] and current['pat'] < latest['pat']):
        return 'upgrade'
    elif (current['min'] > latest['min']) or (current['min'] == latest['min'] and current['pat'] > latest['pat']):
        return 'downgrade'
    else:
        return 'no change'


def filter_valid_versions(version_list):
    valid_versions = []

    for version in version_list:
        try:
            Version(version)
            valid_versions.append(version)
        except InvalidVersion:
            continue

    return valid_versions



def parse_version(version):
    parts = version.split('.')
    return {
        'maj': int(parts[0]),
        'min': int(parts[1]),
        'pat': parts[2] if len(parts) > 2 else 0,
        'ver': version,
        'nodot': version.replace('.', '')
    }


def get_chart_datas():
    chart_data = []
    chart_folder = current_directory + "/charts"
    charts = os.listdir(chart_folder)

    for chart in charts:
        chart_file = chart_folder + f"/{chart}/Chart.yaml"
        if not os.path.exists(chart_file):
            print(f"Chart file not found in '{chart}' folder, skipping")
            continue
        with open(chart_file, "r") as data:
            chart_data.append({"app": chart, "file": chart_file, "data": yaml.safe_load(data)})
    return chart_data


def update_version():
    charts = get_chart_datas()
    for chart in charts:
        chart_data = chart.get('data')
        chart_app_name = chart_data.get('name')

        if chart_data.get('appVersion') == 'latest':
            print(f"App '{chart_app_name}' has not valid version, skipping...")
            continue

        image = chart_data.get('projectUrl').split("github.com/")[1]
        chart_app_version = parse_version(str(chart_data.get('appVersion')))
  
        response = requests.get(f'https://api.github.com/repos/{image}/tags')
        versions = filter_valid_versions([re.sub(r'[a-zA-Z]', '', tag['name']) for tag in response.json()])
        versions.sort(key=Version, reverse=True)
        latest_version = parse_version(versions[0])
        version_status = compare_versions(chart_app_version, latest_version)

        if version_status == 'upgrade-major':
            print(f"App '{chart_app_name}' needs an major-upgrade. ({chart_app_version['ver']} -> {latest_version['ver']})")
            chart_data['majorUpgrade'] = True
        elif version_status == 'downgrade-major':
            print(f"App '{chart_app_name}' needs an major-downgrade. ({chart_app_version['ver']} -> {latest_version['ver']})")
            chart_data['majorDowngrade'] = True
        elif version_status == 'upgrade':
            print(f"App '{chart_app_name}' needs an upgrade. ({chart_app_version['ver']} -> {latest_version['ver']})")
        elif version_status == 'downgrade':
            print(f"App '{chart_app_name}' needs an downgrade. ({chart_app_version['ver']} -> {latest_version['ver']})")
        else:
            print(f"App '{chart_app_name}' is up-to-date.")
            continue

        with open(chart.get('file'), 'w') as f:
            chart_data['appVersion'] = latest_version['ver']
            chart_data['version'] = latest_version['ver']
            yaml.dump(chart_data, f, default_flow_style=False, sort_keys=False, width=float("inf"))


if __name__ == '__main__':
    if current_directory.split("/")[-1] != repository.split("/")[-1]:
        print(f"""Current direcory is not '{repository.split("/")[-1]}', aborting...\n(current directory: {current_directory})""")
        exit(1)
    update_version()
