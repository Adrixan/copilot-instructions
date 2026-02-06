````instructions
---
applyTo: 
  - "**/*.php"
---
<php_standards>
## PHP (Laravel / Symfony)

- **PHP 8.2+** with `declare(strict_types=1);` at top of EVERY file
- **Laravel 10.x** or **Symfony 6.x**
- **Readonly properties** and constructor promotion
- **Testing:** PHPUnit 10 or Pest
- **Static Analysis:** PHPStan (level 8+) or Psalm

See [examples/backend/php/](../examples/backend/php/) for UserService and UserServiceTest patterns.
</php_standards>
````
