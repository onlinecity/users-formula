{% from "users/map.jinja" import users with context %}
include:
  - users

{% for name, user in pillar.get('users', {}).items() if user.absent is not defined or not user.absent %}
{%- set current = salt.user.info(name) -%}
{%- if user == None -%}
{%- set user = {} -%}
{%- endif -%}
{%- set home = user.get('home', current.get('home', "/home/%s" % name)) -%}
{%- set manage = user.get('manage_cshrc', False) -%}
{%- if 'prime_group' in user and 'name' in user['prime_group'] %}
{%- set user_group = user.prime_group.name -%}
{%- else -%}
{%- set user_group = name -%}
{%- endif %}
{%- if manage -%}
users_{{ name }}_user_cshrc:
  file.managed:
    - name: {{ home }}/.cshrc
    - user: {{ name }}
    - group: {{ user_group }}
    - mode: 644
    - source:
      - salt://users/files/cshrc/{{ name }}/cshrc
      - salt://users/files/cshrc/cshrc
{% endif %}
{% endfor %}
