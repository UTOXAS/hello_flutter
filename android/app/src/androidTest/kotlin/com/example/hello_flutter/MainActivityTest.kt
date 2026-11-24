package com.example.hello_flutter

import androidx.test.platform.app.InstrumentationRegistry
import androidx.test.uiautomator.UiDevice // ADDED: change to your package
import org.junit.Test
import org.junit.runner.RunWith
import org.junit.runners.Parameterized
import org.junit.runners.Parameterized.Parameters
import pl.leancode.patrol.PatrolJUnitRunner

@RunWith(Parameterized::class)
class MainActivityTest(private val dartTestName: String) {

    companion object {
        @Parameters(name = "{0}")
        @JvmStatic
        fun testCases(): Array<Any> {
            val instrumentation =
                InstrumentationRegistry.getInstrumentation() as PatrolJUnitRunner
            instrumentation.setUp(MainActivity::class.java)
            instrumentation.waitForPatrolAppService()
            return instrumentation.listDartTests()
        }
    }

    @Test
    fun runDartTest() {
        val instrumentation =
            InstrumentationRegistry.getInstrumentation() as PatrolJUnitRunner
        instrumentation.runDartTest(dartTestName)
    }
}