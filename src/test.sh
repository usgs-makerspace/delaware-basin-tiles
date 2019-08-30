tippecanoe --no-line-simplification --force --output-to-directory tile_dir_simple5 delaware_PRMS_streams.geojson delaware_sites_summary.geojson nhd_hires_flowlines.geojson nhd_hires_waterbodies.geojson

aws s3 sync tile_dir_simple5 s3://delaware-basin-test-website/test_tiles --content-encoding "gzip" --content-type application/x-protobuf --exclude "*.json" --profile chsprod
aws s3 cp tile_dir_simple5/metadata.json s3://delaware-basin-test-website/test_tiles/metadata.json --content-encoding "application/json" --profile chsprod

