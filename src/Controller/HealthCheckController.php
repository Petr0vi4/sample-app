<?php

namespace App\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\Routing\Annotation\Route;

class HealthCheckController extends AbstractController
{
    /**
     * @Route("/health", name="health_check", methods="GET")
     */
    public function index()
    {
        return $this->json([
            'status' => 'OK',
        ]);
    }
}
