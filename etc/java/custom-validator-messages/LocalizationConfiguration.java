package org.gaborbalazs.smartplatform.lotteryservice.application.configuration;

import org.springframework.context.MessageSource;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.support.ResourceBundleMessageSource;

@Configuration
public class LocalizationConfiguration {

    private static final String PATH_MESSAGES = "l10n/messages";
    private static final String CHARACTER_ENCODING = "UTF-8";

    @Bean
    MessageSource messageSource() {
        ResourceBundleMessageSource messageSource = new ResourceBundleMessageSource();
        messageSource.setBasename(PATH_MESSAGES);
        messageSource.setDefaultEncoding(CHARACTER_ENCODING);
        return messageSource;
    }
}
