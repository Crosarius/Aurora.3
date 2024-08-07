/// Log for the garbage collector
/proc/log_subsystem_garbage(text, type, high_severity = FALSE)
#if defined(UNIT_TEST)
	LOG_GITHUB_DEBUG("SSGarbage: [text]")
#else
	WRITE_LOG(GLOB.config.logfiles["garbage_collector_log"], "SSGarbage [text]")
#endif

/proc/log_subsystem_garbage_warning(text, type, high_severity = FALSE)
#if defined(UNIT_TEST)
	LOG_GITHUB_WARNING("SSGarbage: [text]")
#else
	WRITE_LOG(GLOB.config.logfiles["garbage_collector_log"], "SSGarbage [text]")
#endif

/proc/log_subsystem_garbage_error(text, type, high_severity = FALSE)
#if defined(UNIT_TEST)
	LOG_GITHUB_ERROR("SSGarbage: [text]")
#else
	WRITE_LOG(GLOB.config.logfiles["garbage_collector_log"], "SSGarbage [text]")
#endif

/proc/log_subsystem_garbage_harddel(text)
#if defined(UNIT_TEST)
	LOG_GITHUB_ERROR("SSGarbage HARDDEL: [text]")
#else
	WRITE_LOG(GLOB.config.logfiles["harddel_log"], text)
#endif
