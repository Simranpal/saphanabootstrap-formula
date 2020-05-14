{%- from "hana/map.jinja" import hana with context -%}

{% if hana.hana_archive_file is defined %}
{% set hana_package = hana.hana_archive_file %}
{% set hana_extract_dest = hana.hana_extract_dir %}

setup_hana_extract_directory:
    file.directory:
      - name: {{ hana_extract_dest }}
      - mode: 755
      - makedirs: True

{% if (".ZIP" in hana_package) or (".zip" in hana_package) or (".RAR" in hana_package) or (".rar" in hana_package) %}

extract_hana_archive:
    archive.extracted:
      - name: {{ hana_extract_dest }}
      - enforce_toplevel: False
      - source: {{ hana_package }}

{% elif (".exe" in hana_package) or (".EXE" in hana_package) %}

extract_hana_multipart_archive:
  cmd.run:
    - name: unrar x {{ hana_package }}
    - cwd: {{ hana_extract_dest }}

{% elif ((".sar" in hana_package) or (".SAR" in hana_package)) and hana.sapcar_exe_file is defined %}

extract_hdbserver_sar_archive:
    sapcar.extracted:
    - name: {{ hana_package }}
    - sapcar_exe: {{ hana.sapcar_exe_file }}
    - output_dir: {{ hana_extract_dest }}
    - options: "-manifest SIGNATURE.SMF"

copy_signature_file_to_installer_dir:
    file.copy:
    - source: {{ hana_extract_dest }}/SIGNATURE.SMF
    - name: {{ hana_extract_dest }}/SAP_HANA_DATABASE/SIGNATURE.SMF
    - preserve: True
    - force: True
    - require:
        - extract_hdbserver_sar_archive

{% endif %}
{% endif %}