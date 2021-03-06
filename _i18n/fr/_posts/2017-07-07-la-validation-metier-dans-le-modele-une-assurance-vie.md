---
layout: post
title: La validation métier dans le modèle, une assurance vie
summary: Apprendre à valider autrement ses données.
tags:
 - php
 - domain model
 - symfony
 - validation
 - ddd
image: /assets/keep-calm-and-trust-your-model.jpg
redirect_to: /2017/07/07/la-validation-metier-dans-le-modele-une-assurance-vie/
---

Aujourd'hui j'aimerais parler de validation.
Si j'ai envie d'aborder le sujet c'est parce que bien souvent les développeurs ne connaissent qu'une seule façon de faire sans trop se demander si on peut procéder autrement.

### La documentation, un effet perfide

*Symfony*, par exemple,  mais ce n'est pas le seul, est un framework web très bien documenté.
La plupart du temps il suffit de copier-coller un bout de code de ce qui nous intéresse et... *voilà* !
Cette documentation vous explique **comment fonctionne** la librairie, pas de quelle façon elle **s'intègre** le mieux à votre **conception logicielle**.

### Ce que je vois trop souvent

Prenons l'exemple d'une machine à café. Il est possible de configurer le nombre de morceaux de sucre désiré.
Une contrainte métier nous dit que ce nombre ne peut-être qu'un entier supérieur ou égal à 0.

*Symfony* est livré par défaut avec le [composant *validator*](https://github.com/symfony/validator).
Il est facile à utiliser, met à disposition un bon nombre de règles par défaut et sa documentation est plutôt bien foutue.


{% highlight php startinline %}
<?php

// CoffeeMachine.php

use Symfony\Component\Validator\Constraints as Assert;

class CoffeeMachine
{
    /**
     * @Assert\Type("integer")
     * @Assert\GreaterThanOrEqual(0)
     */
    private $numberOfSugarLump = 0;

    public function addSugar($numberOfLump)
    {
        $this->numberOfSugarLump = $numberOfLump;
    }
}

// Controller.php
public function addSugarAction(Request $request, CoffeeMachine $coffeeMachine)
{
    $coffeeMachine->addSugar($request->request->get('numberOfSugarLump'));

    $validator = $this->get('validator');
    $errors = $validator->validate($coffeeMachine);

    if (count($errors) > 0) {
        return $this->render('coffeeMachine/error.html.twig', array(
            'errors' => $errors,
        ));
    }

    $this->get('doctrine.orm.entity_manager')->flush();

    return $this->render('coffeeMachine/success.html.twig');
}
{% endhighlight %}

À première vue, on pourrait se dire que c'est simple, que cela fonctionne très bien et qu'il n'y a aucune raison de faire autrement.

### Oui mais...

Le problème est l'**état** dans lequel se trouve notre modèle `CoffeeMachine`. Si le nombre de morceaux, que l'on récupère depuis l'objet `Request`, est négatif notre machine est dans un état qu'on appelle **invalide**, même pour un court laps de temps.

> Oui c'est normal et c'est pour ça qu'on a notre couche de validation, pour s'assurer qu'on ne persiste pas de mauvaises données.

me direz-vous.

Que se passe t'il si vous ajoutez des morceaux **après** votre couche de validation ?

> Ça n'arrivera jamais, je sais ce que je fais.

Certes, mais si je vous dis que votre équipe technique va être multipliée par 5 durant les prochains mois, que votre *code base* va grossir exponentiellement et donc sa complexité par extension. Si je vous dis que vous allez devoir faire de l'asynchrone, multiplier les sources de données, etc... Même un système de *code review* efficace ne sera pas suffisant pour s'assurer de la cohérence de vos données. Et pour peu que vous vous absentiez un temps, c'est *la fin des haricots*.


### Le métier dans le métier !

{: .center}
![Keep calm and trust your model](/assets/keep-calm-and-trust-your-model.jpg)

Selon moi, ([et bien d'autres](http://codebetter.com/gregyoung/2009/05/22/always-valid/)) vos modèles devraient **toujours** être dans un état valide.
C'est une chose de moins à se soucier.

Quand on y pense, c'est une contrainte business. Elle a toute sa place dans notre **domaine** non ?! Pourquoi l'exclure et la déléguer à notre [couche application](http://dddsample.sourceforge.net/architecture.html) ?

{% highlight php startinline %}
<?php

// CoffeeMachine.php

// Librarie de validation par Benjamin Eberlei.
use Assert\Assertion;

class CoffeeMachine
{
    /**
     * @Assert\Type("integer")
     * @Assert\GreaterThanOrEqual(0)
     */
    private $numberOfSugarLump = 0;

    public function addSugar($numberOfLump)
    {
        Assertion::integer($numberOfLump);
        Assertion::greaterOrEqualThan($numberOfLump, 0);

        $numberOfSugarLump = $numberOfLump;
    }
}
{% endhighlight %}

> Ok mais il y a maintenant deux étapes de validations qui font exactement la même chose, c'est redondant !

Oui et non. Si votre contexte vous force à informer le client des erreurs qu'il aurait pu faire alors vous pouvez considérer votre validation
comme une couche de présentation, rien de plus. C'est juste une couche qui vous permet de formater simplement vos erreurs dans votre `Response`.

Dans certains contextes, cette couche de présentation sera inutile et vous pourrez même la supprimer purement et simplement (mais ça j'en parlerai dans un autre billet).

### Testabilité

Le plus beau dans tout ça c'est que pouvez maintenant tester unitairement votre validation d'un point de vue métier.
Plus besoin de charger un système de test avec tout un tas de détails d'infrastructure (client HTTP, base de données, ...).

{% highlight php startinline %}
<?php

/**
 * @test
 */
public function it_should_add_a_natural_integer_or_zero_number_of_sugar_lump()
{
    $coffeeMachine = new CoffeeMachine();
    $coffeeMachine->addSugar(-1);
    $this->expectException(\InvalidArgumentException::class);
}
{% endhighlight %}

### Conclusion

Mettre de la validation dans le modèle présente de vrais avantages. Cependant ce n'est peut-être pas nécessaire d'en faire aveuglément partout.
Si vous travaillez sur un projet très fortement orienté CRUD, sans beaucoup de logique métier, déléguer la validation à un composant tierce fera l'affaire.
Soyez simplement averti que la complexité d'un projet augmente rapidement et qu'il n'appartient qu'à vous de détecter le moment où les choses se corsent.