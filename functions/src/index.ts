/**
 * Cloud Functions for Tanzania Tourism Platform
 *
 * Functions:
 * - generateItinerary: AI-powered trip planning with Gemini (hard-coded key for now)
 * - createBooking: Create bookings from itineraries
 * - exportToWhatsApp: Export itinerary to WhatsApp
 */

import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { GoogleGenerativeAI } from "@google/generative-ai";

// Initialize Firebase Admin
admin.initializeApp();

const dataConnectEndpoint =
  "https://firebasedataconnect.googleapis.com/v1/projects/book-app-65107445-681db/locations/us-east4/services/gwf-web-prod:executeGraphql";

// ✅ HARDCODED Gemini API key (as requested)
const genAI = new GoogleGenerativeAI(
  "AIzaSyC2FYoVQDGQGk4XOXxF-uFgtdPCB8c2ar8"
);

const allowedOrigins = new Set([
  "http://localhost:5174",
  "http://127.0.0.1:5174",
]);

export const dataConnectProxy = functions.https.onRequest(async (req, res) => {
  const origin = typeof req.headers.origin === "string" ? req.headers.origin : "";
  if (allowedOrigins.has(origin)) {
    res.set("Access-Control-Allow-Origin", origin);
    res.set("Vary", "Origin");
  }
  res.set("Access-Control-Allow-Methods", "POST, OPTIONS");
  res.set("Access-Control-Allow-Headers", "Content-Type, Authorization");

  if (req.method === "OPTIONS") {
    res.status(204).send("");
    return;
  }

  if (req.method !== "POST") {
    res.status(405).send("Method Not Allowed");
    return;
  }

  const authHeader = typeof req.headers.authorization === "string" ? req.headers.authorization : "";
  if (!authHeader.startsWith("Bearer ")) {
    res.status(401).send("Missing Authorization bearer token.");
    return;
  }

  try {
    await admin.auth().verifyIdToken(authHeader.replace("Bearer ", ""));
  } catch (err: any) {
    res.status(401).send(`Invalid token: ${err?.message ?? "Unauthorized"}`);
    return;
  }

  const { query, variables } = req.body ?? {};
  if (!query) {
    res.status(400).send("Missing query.");
    return;
  }

  try {
    const upstream = await fetch(dataConnectEndpoint, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: authHeader,
      },
      body: JSON.stringify({ query, variables }),
    });
    const text = await upstream.text();
    res.status(upstream.status).set("Content-Type", upstream.headers.get("content-type") ?? "text/plain").send(text);
  } catch (err: any) {
    res.status(502).send(`Proxy error: ${err?.message ?? "Unknown error"}`);
  }
});

// =======================
// Types (lightweight)
// =======================
type Audience = "international" | "local";
type Budget = "budget" | "mid-range" | "luxury";
type TravelPace = "relaxed" | "moderate" | "packed";
type TravelMode = "road" | "flight" | "mixed";

interface GenerateItineraryInput {
  days: number;
  groupSize?: number;
  interests?: string[];
  travelPace?: TravelPace;
  budget: Budget;
  audience: Audience;
  arrivalAirport?: string;
  needFlights?: boolean;
  startingCity?: string;
  travelMode?: TravelMode;
}

interface CreateBookingInput {
  itineraryId: string;
  contactInfo?: any;
  specialRequests?: string;
}

interface ExportWhatsAppInput {
  itineraryId: string;
}

interface ItineraryDay {
  day: number;
  title: string;
  location: string;
  activities: string[];
  accommodation: string;
  meals: string;
}

interface Itinerary {
  title: string;
  summary: string;
  whyThis?: string;
  priceEstimate: number;
  currency: "USD" | "TZS";
  itineraryDays: ItineraryDay[];
  included: string[];
  importantNotes?: string[];
}

// =======================
// Helpers
// =======================
function extractJson(text: string): any {
  let t = text.trim();

  // remove markdown fences if any
  if (t.startsWith("```")) {
    t = t.replace(/```json|```/g, "").trim();
  }

  // grab the first JSON object
  const start = t.indexOf("{");
  const end = t.lastIndexOf("}");
  if (start === -1 || end === -1 || end <= start) {
    throw new Error("No JSON object found in AI response");
  }

  return JSON.parse(t.slice(start, end + 1));
}

function fallbackPrice(days: number, budget: Budget, audience: Audience): number {
  const rates = {
    international: { budget: 200, "mid-range": 325, luxury: 600 },
    local: { budget: 400000, "mid-range": 650000, luxury: 1200000 },
  } as const;

  return days * (rates[audience][budget] ?? 200);
}

function buildItineraryPrompt(input: GenerateItineraryInput): string {
  const {
    audience,
    days,
    budget,
    interests = [],
    travelPace = "moderate",
    groupSize = 1,
    travelMode = "mixed",
    arrivalAirport,
    startingCity,
    needFlights,
  } = input;

  const currency = audience === "international" ? "USD" : "TZS";
  const modeText =
    travelMode === "mixed" ? "mix of flights and road transfers" : travelMode;

  const extra = [
    arrivalAirport ? `Arrival Airport: ${arrivalAirport}` : null,
    startingCity ? `Starting City: ${startingCity}` : null,
    typeof needFlights === "boolean" ? `Need Flights: ${needFlights ? "Yes" : "No"}` : null,
  ]
    .filter(Boolean)
    .join("\n");

  return `
You are a professional Tanzania tour planner.

Create a realistic ${days}-day Tanzania itinerary.

TRAVELER PROFILE:
- Audience: ${audience}
- Budget: ${budget}
- Currency: ${currency}
- Group size: ${groupSize}
- Travel pace: ${travelPace}
- Interests: ${interests.join(", ") || "General Tanzania highlights"}
- Travel mode: ${modeText}
${extra ? `\n${extra}\n` : ""}

RULES:
- Use real Tanzania destinations (Serengeti, Ngorongoro, Tarangire, Manyara, Zanzibar, Kilimanjaro, Mikumi, Nyerere/Ruaha as relevant).
- Keep travel times realistic (avoid impossible same-day jumps).
- Provide suitable accommodations for the budget tier.
- Return ONLY valid JSON (no markdown, no extra text).
- priceEstimate MUST be a NUMBER (not a formula).

OUTPUT JSON schema:
{
  "title": "Trip title",
  "summary": "Short overview",
  "whyThis": "Why this plan fits",
  "priceEstimate": 12345,
  "currency": "${currency}",
  "itineraryDays": [
    {
      "day": 1,
      "title": "Day title",
      "location": "Main location",
      "activities": ["Activity 1", "Activity 2", "Activity 3"],
      "accommodation": "Hotel/Lodge name",
      "meals": "Breakfast, Lunch, Dinner"
    }
  ],
  "included": ["Included item 1", "Included item 2"],
  "importantNotes": ["Note 1", "Note 2"]
}
`;
}

function normalizeItinerary(
  raw: any,
  input: GenerateItineraryInput
): Itinerary {
  const currency: "USD" | "TZS" =
    input.audience === "international" ? "USD" : "TZS";

  const daysArr: ItineraryDay[] = Array.isArray(raw?.itineraryDays)
    ? raw.itineraryDays.map((d: any, idx: number) => ({
        day: Number(d?.day ?? idx + 1),
        title: String(d?.title ?? `Day ${idx + 1}`),
        location: String(d?.location ?? "Tanzania"),
        activities: Array.isArray(d?.activities)
          ? d.activities.map((a: any) => String(a)).slice(0, 12)
          : [],
        accommodation: String(d?.accommodation ?? "To be confirmed"),
        meals: String(d?.meals ?? "Breakfast, Lunch, Dinner"),
      }))
    : [];

  const included: string[] = Array.isArray(raw?.included)
    ? raw.included.map((x: any) => String(x)).slice(0, 20)
    : [];

  const importantNotes: string[] = Array.isArray(raw?.importantNotes)
    ? raw.importantNotes.map((x: any) => String(x)).slice(0, 20)
    : [];

  const pe =
    Number(raw?.priceEstimate) > 0
      ? Number(raw.priceEstimate)
      : fallbackPrice(input.days, input.budget, input.audience);

  return {
    title: raw?.title ? String(raw.title) : `${input.days}-Day Tanzania Adventure`,
    summary: raw?.summary ? String(raw.summary) : "Custom Tanzania itinerary.",
    whyThis: raw?.whyThis ? String(raw.whyThis) : undefined,
    priceEstimate: pe,
    currency,
    itineraryDays: daysArr,
    included,
    importantNotes,
  };
}

// =======================
// generateItinerary
// =======================
export const generateItinerary = functions.https.onCall(
  async (data: GenerateItineraryInput, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "User must be authenticated to generate itineraries"
      );
    }

    const input: GenerateItineraryInput = {
      ...data,
      groupSize: data.groupSize ?? 1,
      interests: Array.isArray(data.interests) ? data.interests : [],
      travelPace: data.travelPace ?? "moderate",
      travelMode: data.travelMode ?? "mixed",
    };

    if (!input.days || !input.budget || !input.audience) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Missing required fields: days, budget, or audience"
      );
    }

    if (input.days < 1 || input.days > 21) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "days must be between 1 and 21"
      );
    }

    const userId = context.auth.uid;
    const prompt = buildItineraryPrompt(input);

    let aiText = "";
    try {
      functions.logger.info("Generating itinerary", { userId, days: input.days });

      // ✅ Use a supported model first. (Flash caused 404 for you.)
      // If you later regain access to flash, you can switch back.
      const model = genAI.getGenerativeModel({ model: "gemini-1.5-pro" });

      const result = await model.generateContent(prompt);
      aiText = result.response.text();
    } catch (error: any) {
      functions.logger.error("Gemini generateContent failed", error);
      throw new functions.https.HttpsError(
        "internal",
        "Gemini API failed",
        error?.message || "Unknown Gemini error"
      );
    }

    let itinerary: Itinerary;
    try {
      const raw = extractJson(aiText);
      itinerary = normalizeItinerary(raw, input);
    } catch (err) {
      // fallback if JSON parsing fails
      itinerary = {
        title: `${input.days}-Day Tanzania Adventure`,
        summary: aiText.slice(0, 300) || "Custom Tanzania itinerary.",
        priceEstimate: fallbackPrice(input.days, input.budget, input.audience),
        currency: input.audience === "international" ? "USD" : "TZS",
        itineraryDays: [],
        included: [],
        importantNotes: ["AI output could not be parsed as JSON. Please regenerate."],
      };
    }

    const itineraryRef = await admin.firestore().collection("itineraries").add({
      userId,
      audience: input.audience,
      preferences: input,
      itinerary,
      rawAiResponse: aiText,
      status: "draft",
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return {
      success: true,
      itineraryId: itineraryRef.id,
      itinerary,
    };
  }
);

// =======================
// createBooking
// =======================
export const createBooking = functions.https.onCall(
  async (data: CreateBookingInput, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError("unauthenticated", "User must be authenticated");
    }

    if (!data?.itineraryId) {
      throw new functions.https.HttpsError("invalid-argument", "itineraryId is required");
    }

    const userId = context.auth.uid;

    try {
      const itineraryDoc = await admin
        .firestore()
        .collection("itineraries")
        .doc(data.itineraryId)
        .get();

      if (!itineraryDoc.exists) {
        throw new functions.https.HttpsError("not-found", "Itinerary not found");
      }

      if (itineraryDoc.data()?.userId !== userId) {
        throw new functions.https.HttpsError("permission-denied", "Not authorized");
      }

      const bookingRef = await admin.firestore().collection("bookings").add({
        userId,
        itineraryId: data.itineraryId,
        contactInfo: data.contactInfo ?? null,
        specialRequests: data.specialRequests ?? null,
        status: "pending",
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      await itineraryDoc.ref.update({
        status: "booking_requested",
        bookingId: bookingRef.id,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      return { success: true, bookingId: bookingRef.id };
    } catch (error: any) {
      functions.logger.error("Error creating booking", error);
      throw new functions.https.HttpsError(
        "internal",
        "Failed to create booking",
        error?.message || "Unknown error"
      );
    }
  }
);

// =======================
// exportToWhatsApp
// =======================
export const exportToWhatsApp = functions.https.onCall(
  async (data: ExportWhatsAppInput, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError("unauthenticated", "User must be authenticated");
    }

    if (!data?.itineraryId) {
      throw new functions.https.HttpsError("invalid-argument", "itineraryId is required");
    }

    const userId = context.auth.uid;

    try {
      const itineraryDoc = await admin
        .firestore()
        .collection("itineraries")
        .doc(data.itineraryId)
        .get();

      if (!itineraryDoc.exists) {
        throw new functions.https.HttpsError("not-found", "Itinerary not found");
      }

      if (itineraryDoc.data()?.userId !== userId) {
        throw new functions.https.HttpsError("permission-denied", "Not authorized");
      }

      const itinerary = itineraryDoc.data()?.itinerary as Itinerary;
      const whatsappText = formatForWhatsApp(itinerary);

      await itineraryDoc.ref.update({
        exportedToWhatsApp: true,
        lastExportedAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      return {
        success: true,
        whatsappText,
        whatsappUrl: `https://wa.me/?text=${encodeURIComponent(whatsappText)}`,
      };
    } catch (error: any) {
      functions.logger.error("Error exporting to WhatsApp", error);
      throw new functions.https.HttpsError(
        "internal",
        "Failed to export to WhatsApp",
        error?.message || "Unknown error"
      );
    }
  }
);

// =======================
// WhatsApp Formatter
// =======================
function formatForWhatsApp(itinerary: Itinerary): string {
  let text = `🇹🇿 *${itinerary.title}*\n\n`;
  text += `${itinerary.summary}\n\n`;
  text += `💰 *Estimated Cost:* ${itinerary.currency} ${Number(
    itinerary.priceEstimate || 0
  ).toLocaleString()}\n\n`;

  if (Array.isArray(itinerary.itineraryDays) && itinerary.itineraryDays.length) {
    text += "📅 *ITINERARY*\n\n";
    itinerary.itineraryDays.forEach((day) => {
      text += `*Day ${day.day}: ${day.title}*\n`;
      text += `📍 ${day.location}\n`;
      (day.activities || []).slice(0, 6).forEach((a) => {
        text += `• ${a}\n`;
      });
      text += `🏨 ${day.accommodation}\n`;
      text += `🍽️ ${day.meals}\n\n`;
    });
  }

  if (Array.isArray(itinerary.included) && itinerary.included.length) {
    text += "✅ *Included:*\n";
    itinerary.included.slice(0, 10).forEach((i) => (text += `• ${i}\n`));
    text += "\n";
  }

  if (Array.isArray(itinerary.importantNotes) && itinerary.importantNotes.length) {
    text += "⚠️ *Important Notes:*\n";
    itinerary.importantNotes.slice(0, 10).forEach((n) => (text += `• ${n}\n`));
    text += "\n";
  }

  text += "🦁 Generated by Tembo Tanzania Tours";

  return text;
}
