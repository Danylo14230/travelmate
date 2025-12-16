import org.gradle.api.tasks.Delete
import java.io.File

buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.google.gms:google-services:4.4.0")
        classpath("com.google.firebase:firebase-crashlytics-gradle:2.9.9")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

/**
 * ✅ ВАЖЛИВО ДЛЯ FLUTTER:
 * переносимо build output в кореневий ./build
 * інакше flutter build інколи не знаходить apk (особливо з flavors) і падає.
 */
rootProject.buildDir = File(rootDir, "../build")

subprojects {
    buildDir = File(rootProject.buildDir, name)
}

subprojects {
    evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.buildDir)
}
