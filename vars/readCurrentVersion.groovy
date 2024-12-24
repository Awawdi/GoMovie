def call(String versionFile, String versionIncrement) {
    if (fileExists(versionFile)) {
        def versionContent = readFile(versionFile).trim()
        def versionParts = versionContent.tokenize('.')

        if (versionParts.size() == 3) {
            MAJOR_VERSION = versionParts[0].toInteger()
            MINOR_VERSION = versionParts[1].toInteger()
            PATCH_VERSION = versionParts[2].toInteger()
        } else {
            error("Invalid version format in ${versionFile}. Expected format: x.y.z")
        }
    } else {
        MAJOR_VERSION = 1
        MINOR_VERSION = 0
        PATCH_VERSION = 0
    }

    if (versionIncrement == 'MAJOR') {
        MAJOR_VERSION++
        MINOR_VERSION = 0
        PATCH_VERSION = 0
    } else if (versionIncrement == 'MINOR') {
        MINOR_VERSION++
        PATCH_VERSION = 0
    } else if (versionIncrement == 'PATCH') {
        PATCH_VERSION++
    } else {
        error("Invalid VERSION_INCREMENT parameter: ${versionIncrement}")
    }

    IMAGE_TAG = "${MAJOR_VERSION}.${MINOR_VERSION}.${PATCH_VERSION}"
    env.IMAGE_TAG = IMAGE_TAG
    echo "Generated IMAGE_TAG: ${IMAGE_TAG}"
}
