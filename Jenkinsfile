pipeline {
  agent {
        node {
            label 'node:slave'
        }
    }
    parameters {
        gitParameter name: 'BRANCH_TAG',
                     type: 'PT_BRANCH_TAG',
                     defaultValue: 'master'
        choice(choices: ['test', 'prod'], description: 'Tier to deploy tiles to', name: 'TIER')
    }
  stages {
    stage('Clean Workspace') {
	    steps{
		    cleanWs()
	     }
	  }
    stage('Checkout repo and pull from S3') {
      steps {
        sh 'wget -O DOIRootCA2.cer http://sslhelp.doi.net/docs/DOIRootCA2.cer'
          checkout([$class: 'GitSCM',
                          branches: [[name: "${params.BRANCH_TAG}"]],
                          doGenerateSubmoduleConfigurations: false,
                          extensions: [],
                          gitTool: 'Default',
                          submoduleCfg: [],
                          userRemoteConfigs: [[url: 'https://github.com/usgs-makerspace/delaware-basin-tiles.git']]
                        ])
          sh 'aws s3 sync s3://prod-owi-resources/resources/Application/delaware-basin/data_sets .'
      }
    }
    stage('create tileset') {
      agent {
        docker {
          image 'code.chs.usgs.gov:5001/wma/iidd/wbeep-data-processing:tippecanoe-latest'
          registryUrl 'https://code.chs.usgs.gov:5001/wma/iidd/wbeep-data-processing'
          registryCredentialsId 'jenkins_ci_access_token'
          alwaysPull true
          reuseNode true
        } 
      }
      steps {
        sh 'tippecanoe --no-tile-size-limit --simplify-only-low-zooms --base-zoom 3 --force --output-to-directory tile_dir delaware_PRMS_streams.geojson delaware_sites_summary.geojson nhd_hires_flowlines.geojson nhd_hires_waterbodies.geojson'
      }
    }
    stage('push to S3') {
      steps { 
        sh '''
          aws s3 sync tile_dir s3://delaware-basin-${TIER}-website/tiles --content-encoding "gzip" --content-type application/x-protobuf --exclude "*.json"  --delete
          aws s3 cp tile_dir/metadata.json s3://delaware-basin-${TIER}-website/tiles/metadata.json --content-encoding "application/json" 
          '''
      }
    }
  }
}
