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
    elif ((current['min'] < latest['min']) or (current['min'] > latest['min'])):
        return 'minor'
    elif ((current['pat'] < latest['pat']) or (current['pat'] > latest['pat'])):
        return 'patch'
    else:
        return 'no change'


def filter_valid_versions(version_list):
    valid_versions = []
    version_list = [re.sub(r'^v', '', version) for version in version_list]

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
        'pat': parts[2] if len(parts) > 2 else '0',
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

        project_url = chart_data.get('projectUrl')
        chart_app_version = parse_version(str(chart_data.get('appVersion')))
        chart_version = parse_version(str(chart_data.get('version')))
        
        versions = []
        try:
            if 'github.com' in project_url:
                image = project_url.split("github.com/")[1]
                response = requests.get(f'https://api.github.com/repos/{image}/tags')
                versions.extend(filter_valid_versions([tag['name'] for tag in response.json() if re.match(r'^v?\d{,3}\.\d{,3}\.\d{,3}$', tag['name'])]))
                versions.sort(key=Version, reverse=True)
                if not versions:
                    response = requests.get(f'https://api.github.com/repos/{image}/releases/latest')
                    versions.extend(filter_valid_versions([re.sub(r'[a-zA-Z]', '', response.json()['tag_name'])]))
                    versions.sort(key=Version, reverse=True)
            else:
                path_parts = project_url.strip('/').split('/')[-2:]
                if path_parts[0] == '_':
                    org_repo = 'library/' + path_parts[1]
                else:
                    org_repo = '/'.join(path_parts[:2])
                
                response = requests.get(f'https://hub.docker.com/v2/repositories/{org_repo}/tags?page_size=100')
                if response.status_code == 200:
                    versions.extend(filter_valid_versions([tag['name'] for tag in response.json()['results']]))
                    versions.sort(key=Version, reverse=True)
                
            if not versions:
                print(f"No valid versions found for '{chart_app_name}' from '{project_url}'")
                continue
                
        except Exception as e:
            print(f"Failed to get versions for '{chart_app_name}' from '{project_url}'")
            print('=======================\nError:', e)
            continue
        latest_version = parse_version(versions[0])
        try:
            version_status = compare_versions(chart_app_version, latest_version)
        except:
            print(f"Compare versions failed for '{chart_app_name}' ['{chart_app_version['ver']}' <-> '{latest_version['ver']}']")
            continue

        match (version_status):
            case 'upgrade-major':
                print(f"App '{chart_app_name}' needs an major-upgrade. ({chart_app_version['ver']} -> {latest_version['ver']})")
                chart_version['maj'] += 1
                chart_version['min'] = 0
                chart_version['pat'] = str(int(chart_version['pat']) + 1)
                chart_data['majorUpgrade'] = True
            case 'downgrade-major':
                print(f"App '{chart_app_name}' needs an major-downgrade. ({chart_app_version['ver']} -> {latest_version['ver']})")
                chart_version['pat'] = str(int(chart_version['pat']) + 1)
                chart_data['majorDowngrade'] = True
            case 'minor':
                chart_version['min'] += 1
                chart_version['pat'] = str(0)
            case 'patch':
                chart_version['pat'] = str(int(chart_version['pat']) + 1)
            case _:
                print(f"App '{chart_app_name}' is up-to-date.")
                continue

        with open(chart.get('file'), 'w') as f:
            chart_data['appVersion'] = latest_version['ver']
            chart_data['version'] = f"{chart_version['maj']}.{chart_version['min']}.{chart_version['pat']}"
            yaml.dump(chart_data, f, default_flow_style=False, sort_keys=False, width=float("inf"))


if __name__ == '__main__':
    if current_directory.split("/")[-1] != repository.split("/")[-1]:
        print(f"""Current direcory is not '{repository.split("/")[-1]}', aborting...\n(current directory: {current_directory})""")
        exit(1)
    update_version()
